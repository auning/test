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
mkdir -p $PROJECT_DIR && cd $PROJECT_DIR
devbox init

# 添加常用工具和 Python 依赖
devbox add python@3.11 nodejs@18 git

# 创建 devbox.json 配置文件，添加 Django 依赖
cat > devbox.json << EOL
{
  "packages": [
    "python@3.11",
    "nodejs@18",
    "git"
  ],
  "shell": {
    "init_hook": [
      "pip install django"
    ]
  }
}
EOL

# 创建自动启动Django项目的脚本
cat > setup_django.sh << EOL
#!/bin/bash
# 检查Django项目是否已存在
if [ ! -d "myproject" ]; then
    echo "创建新的Django项目..."
    django-admin startproject myproject .
    python manage.py startapp myapp
    
    # 创建一个简单的视图
    cat > myapp/views.py << EOF
from django.http import HttpResponse

def index(request):
    return HttpResponse("欢迎使用Django! 开发环境已成功设置。")
EOF
    
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
fi

# 启动Django服务器
python manage.py runserver 0.0.0.0:8000
EOL

# 使脚本可执行
chmod +x setup_django.sh

# 创建自定义启动命令
mkdir -p .devbox/hooks
cat > .devbox/hooks/start.sh << EOL
#!/bin/bash
cd $PROJECT_DIR
./setup_django.sh
EOL
chmod +x .devbox/hooks/start.sh

# 生成启动命令指南
echo "✅ Django Devbox 环境已配置！执行以下命令："
echo "cd $PROJECT_DIR && devbox shell"
echo ""
echo "进入 devbox shell 后，执行以下命令启动 Django："
echo "./setup_django.sh"
echo ""
echo "或者使用快捷命令启动："
echo "devbox run start"
echo ""
echo "Django 服务器将运行在: http://localhost:8000"