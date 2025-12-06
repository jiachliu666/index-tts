#!/bin/bash

# TTS 调用脚本
# 用法: ./run_tts.sh <speaker_audio> <text> <output_path>
# 或者: ./run_tts.sh <speaker_audio> <output_path> --file <text_file>

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 设置项目根目录（index-tts 项目的路径）
PROJECT_DIR="$SCRIPT_DIR"

# venv 路径（假设在项目根目录下）
VENV_PATH="$PROJECT_DIR/venv"

# 检查 venv 是否存在
if [ ! -d "$VENV_PATH" ]; then
    echo "错误: 找不到虚拟环境 $VENV_PATH"
    echo "请先创建虚拟环境: python -m venv venv"
    exit 1
fi

# 激活虚拟环境
source "$VENV_PATH/bin/activate"

# 切换到项目目录（因为 main.py 中使用了相对路径 checkpoints/）
cd "$PROJECT_DIR"

# 调用 Python 脚本，传递所有参数
python "$PROJECT_DIR/main.py" "$@"

# 保存退出码
EXIT_CODE=$?

# 退出虚拟环境
deactivate

# 返回原始退出码
exit $EXIT_CODE
