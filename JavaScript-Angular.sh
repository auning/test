#!/bin/bash
# 检查是否在 WSL2 中运行（可选）
if ! grep -q "WSL2" /proc/version 2&gt;/dev/null; then
echo "⚠️ 请在 WSL2 的 Linux 环境中运行此脚本！"
exit 1
fi

# 安装 Devbox（如果未安装）
if ! command -v devbox &amp;&gt; /dev/null; then
echo "安装 Devbox..."
curl -fsSL https://get.jetpack.io/devbox | bash
# 将 Devbox 添加到 PATH（针对 WSL2 的 Shell 配置）
echo 'export PATH="$PATH:$HOME/.devbox/bin"' &gt;&gt; ~/.bashrc
source ~/.bashrc
fi

# 初始化项目目录
mkdir -p ~/devbox-projects/my-project &amp;&amp; cd ~/devbox-projects/my-project
devbox init

# 添加常用工具（示例）
devbox add python@3.11 nodejs@18 git

# 生成启动命令（兼容 WSL2 的路径）
echo "✅ Devbox 环境已配置！运行以下命令进入："
echo "cd ~/devbox-projects/my-project &amp;&amp; devbox shell"