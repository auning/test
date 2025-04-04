#!/bin/bash
# 检查是否在 WSL2 中运行（可选）
if ! grep -q "WSL2" /proc/version 2>/dev/null; then
    echo "⚠️ 请在 WSL2 的 Linux 环境中运行此脚本！"
    exit 1
fi

# 安装 Devbox（如果未安装）
if ! command -v devbox &> /dev/null; then
    echo "安装 Devbox..."
    curl -fsSL https://get.jetpack.io/devbox | bash
    # 将 Devbox 添加到 PATH（针对 WSL2 的 Shell 配置）
    echo 'export PATH="$PATH:$HOME/.devbox/bin"' >> ~/.bashrc
    source ~/.bashrc
fi

# 初始化项目目录
PROJECT_DIR=~/devbox-projects/django-project
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# 初始化devbox项目
if [ ! -f "devbox.json" ]; then
    echo "初始化Devbox项目..."
    devbox init
    
    # 添加常用工具和 Python 依赖
    devbox add python@3.11 nodejs@18 git

    # 更新devbox.json以自动激活虚拟环境
    cat > devbox.json << EOL
{
  "packages": [
    "python@3.11",
    "nodejs@18",
    "git"
  ],
  "shell": {
    "init_hook": [
      ". \$VENV_DIR/bin/activate",
      "pip install django",
      "pip install djangorestframework"
    ]
  }
}
EOL
fi

# 创建启动Django的脚本
cat > start_django.sh << EOL
#!/bin/bash
set -e  # 出错时停止执行

# 确保虚拟环境被激活
if [ -z "\$VIRTUAL_ENV" ]; then
    echo "正在激活虚拟环境..."
    . \$VENV_DIR/bin/activate
fi

# 确保Django已安装
if ! python -c "import django" &>/dev/null; then
    echo "正在安装Django..."
    pip install django
fi

# 检查Django项目是否已存在
if [ ! -f "manage.py" ]; then
    echo "创建新的Django项目..."
    django-admin startproject myproject .
    python manage.py startapp myapp
    
    # 创建一个简单的视图
    mkdir -p myapp
    cat > myapp/views.py << EOF
from django.http import HttpResponse

def index(request):
    return HttpResponse("欢迎使用Django! 开发环境已成功设置。")
EOF
    
    # 等待项目创建完成
    sleep 2
    
    # 配置URL
    cat > myproject/urls.py << EOF
from django.contrib import admin
from django.urls import path
from myapp import views

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', views.index, name='index'),
]
EOF
    
    # 修改settings.py添加新应用
    sed -i "s/INSTALLED_APPS = \[/INSTALLED_APPS = \[\n    'myapp',/" myproject/settings.py
    
    # 初始化数据库
    python manage.py migrate
	
	# 检查是否已创建超级用户
	if ! python manage.py shell -c "from django.contrib.auth import get_user_model; print(get_user_model().objects.filter(is_superuser=True).exists())" | grep -q "True"; then
		echo "创建超级用户admin (密码: admin123)..."
		python manage.py shell -c "
	from django.contrib.auth import get_user_model;
	User = get_user_model();
	if not User.objects.filter(username='admin').exists():
		User.objects.create_superuser('admin', 'admin@example.com', 'admin123')
	"
		echo "超级用户已创建! 用户名: admin, 密码: admin123"
	fi
fi

echo "启动Django服务器..."
python manage.py runserver 0.0.0.0:8000
EOL

# 使脚本可执行
chmod +x start_django.sh

# 创建运行脚本
cat > run_django.sh << EOL
#!/bin/bash
cd $PROJECT_DIR
CURRENT_SHELL=\$SHELL
devbox run --pure bash -c "./start_django.sh"
EOL
chmod +x run_django.sh

# 提供指南
echo "✅ Django Devbox 环境已配置！"
echo ""
echo "运行Django的方法："
echo "1. 进入项目目录后直接运行："
echo "   cd $PROJECT_DIR && devbox run --pure bash -c './start_django.sh'"
echo ""
echo "2. 或使用快捷脚本："
echo "   $PROJECT_DIR/run_django.sh"
echo ""
echo "现在尝试启动Django服务器..."

# 尝试启动，确保使用--pure标志创建干净的环境
cd $PROJECT_DIR
devbox run --pure bash -c './start_django.sh'