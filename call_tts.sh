#!/bin/bash

# 外部调用 TTS 的脚本
# 用法: ./call_tts.sh <speaker_audio> <text> <output_path>
# 或者: ./call_tts.sh <speaker_audio> <output_path> --file <text_file>

# ========== 配置区域 ==========
# 修改这里为你的 index-tts 项目路径
INDEX_TTS_DIR="/Users/jiachengliu/Documents/index-tts"

# venv 路径（相对于 INDEX_TTS_DIR）
VENV_PATH="$INDEX_TTS_DIR/venv"
# ==============================

# 检查项目目录是否存在
if [ ! -d "$INDEX_TTS_DIR" ]; then
    echo "错误: 找不到 index-tts 项目目录: $INDEX_TTS_DIR"
    echo "请修改脚本中的 INDEX_TTS_DIR 变量"
    exit 1
fi

# 检查 venv 是否存在
if [ ! -d "$VENV_PATH" ]; then
    echo "错误: 找不到虚拟环境: $VENV_PATH"
    echo "请先在 index-tts 项目中创建虚拟环境: python -m venv venv"
    exit 1
fi

# 检查参数
if [ $# -lt 3 ]; then
    echo "用法: $0 <speaker_audio> <text> <output_path>"
    echo "或者: $0 <speaker_audio> <output_path> --file <text_file>"
    echo ""
    echo "示例:"
    echo "  $0 examples/lbw.m4a \"你好，世界！\" output.wav"
    echo "  $0 examples/lbw.m4a output.wav --file input.txt"
    exit 1
fi

# 激活虚拟环境
source "$VENV_PATH/bin/activate"

# 保存当前目录
ORIGINAL_DIR="$(pwd)"

# 切换到 index-tts 项目目录
cd "$INDEX_TTS_DIR"

# 构建参数
SPEAKER_AUDIO="$1"
shift

# 如果 speaker_audio 是相对路径，转换为绝对路径（相对于调用目录）
if [[ ! "$SPEAKER_AUDIO" = /* ]]; then
    SPEAKER_AUDIO="$ORIGINAL_DIR/$SPEAKER_AUDIO"
fi

# 检查是否使用 --file 参数
if [ "$2" = "--file" ] || [ "$2" = "-f" ]; then
    TEXT_OR_OUTPUT="$1"
    FILE_FLAG="$2"
    TEXT_FILE="$3"
    
    # 如果输出路径是相对路径，转换为绝对路径
    if [[ ! "$TEXT_OR_OUTPUT" = /* ]]; then
        TEXT_OR_OUTPUT="$ORIGINAL_DIR/$TEXT_OR_OUTPUT"
    fi
    
    # 如果文本文件是相对路径，转换为绝对路径
    if [[ ! "$TEXT_FILE" = /* ]]; then
        TEXT_FILE="$ORIGINAL_DIR/$TEXT_FILE"
    fi
    
    # 调用 Python 脚本
    uv run "$INDEX_TTS_DIR/main.py" -s "$SPEAKER_AUDIO" -o "$TEXT_OR_OUTPUT" -f "$TEXT_FILE"
else
    # 直接传入文本
    TEXT="$1"
    OUTPUT="$2"
    
    # 如果输出路径是相对路径，转换为绝对路径
    if [[ ! "$OUTPUT" = /* ]]; then
        OUTPUT="$ORIGINAL_DIR/$OUTPUT"
    fi
    
    # 调用 Python 脚本
    python "$INDEX_TTS_DIR/main.py" -s "$SPEAKER_AUDIO" -t "$TEXT" -o "$OUTPUT"
fi

# 保存退出码
EXIT_CODE=$?

# 返回原始目录
cd "$ORIGINAL_DIR"

# 退出虚拟环境
deactivate

# 返回原始退出码
exit $EXIT_CODE
