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
PROJECT_DIR=~/devbox-projects/react-project
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# 初始化devbox项目
if [ ! -f "devbox.json" ]; then
    echo "初始化Devbox项目..."
    devbox init
    
    # 添加常用工具和 Node.js 依赖
    devbox add nodejs@18 git npm

    # 更新devbox.json以添加自定义启动命令
    cat > devbox.json << 'EOL'
{
  "packages": [
    "nodejs@18",
    "git",
    "npm"
  ],
  "shell": {
    "init_hook": [],
    "scripts": {
      "start": "./start_react.sh",
      "build": "cd react-app && npm run build",
      "serve": "cd react-app && npx serve -s build"
    }
  }
}
EOL
fi

# 创建启动React的脚本
cat > start_react.sh << 'EOL'
#!/bin/bash
set -e  # 出错时停止执行

# 确保npm和npx可用
if ! command -v npm &> /dev/null || ! command -v npx &> /dev/null; then
    echo "安装npm..."
    # 对于Ubuntu/Debian系统
    if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y npm
    # 对于Fedora系统
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y npm
    # 对于其他系统
    else
        echo "请手动安装npm，然后再运行此脚本"
        exit 1
    fi
fi

# 检查React项目是否已存在
if [ ! -d "react-app" ]; then
    echo "创建新的React项目..."
    # 使用npx而不是全局安装
    npx create-react-app react-app
    
    # 进入项目目录
    cd react-app
    
    # 添加几个常用的依赖
    npm install axios react-router-dom
    
    # 创建自定义样式文件
    mkdir -p src/styles
    cat > src/styles/App.css << EOF
// ... existing code ...
EOF

    # 修改App.js创建一个美观的欢迎页面
    cat > src/App.js << EOF
// ... existing code ...
EOF

    # 自定义标题
    sed -i 's/<title>React App<\/title>/<title>Devbox React 项目<\/title>/' public/index.html
    
    echo "React项目创建完成并添加了基本样式和组件！"
else
    cd react-app
fi

# 启动React开发服务器
echo "启动React开发服务器..."
npm start
EOL

# 使脚本可执行
chmod +x start_react.sh

# 创建运行脚本
cat > run_react.sh << 'EOL'
#!/bin/bash
cd "$PROJECT_DIR"
devbox shell -- bash -c "./start_react.sh"
EOL
sed -i "s|\$PROJECT_DIR|$PROJECT_DIR|g" run_react.sh
chmod +x run_react.sh

# 创建构建脚本
cat > build_react.sh << 'EOL'
#!/bin/bash
cd "$PROJECT_DIR"
devbox shell -- bash -c "cd react-app && npm run build"
EOL
sed -i "s|\$PROJECT_DIR|$PROJECT_DIR|g" build_react.sh
chmod +x build_react.sh

# 创建预览生产版本脚本
cat > serve_build.sh << 'EOL'
#!/bin/bash
cd "$PROJECT_DIR"
devbox shell -- bash -c "cd react-app && npx serve -s build"
EOL
sed -i "s|\$PROJECT_DIR|$PROJECT_DIR|g" serve_build.sh
chmod +x serve_build.sh

# 提供指南
echo "✅ React Devbox 环境已配置！"
echo ""
echo "运行React开发服务器："
echo "1. 进入项目目录后运行："
echo "   cd $PROJECT_DIR && devbox run start"
echo ""
echo "2. 或使用快捷脚本："
echo "   $PROJECT_DIR/run_react.sh"
echo ""
echo "构建生产版本："
echo "   $PROJECT_DIR/build_react.sh"
echo ""
echo "预览生产版本："
echo "   $PROJECT_DIR/serve_build.sh"
echo ""
echo "现在尝试启动React开发服务器..."

# 尝试启动
cd $PROJECT_DIR
devbox shell -- bash -c './start_react.sh' 