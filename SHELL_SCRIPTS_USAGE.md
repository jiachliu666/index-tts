# TTS Shell 脚本使用说明

本目录包含两个 shell 脚本，用于简化 IndexTTS 的调用。

## 脚本文件

### 1. `run_tts.sh` - 本地运行脚本
在 index-tts 项目目录内使用，自动激活 venv 并运行 TTS。

### 2. `call_tts.sh` - 外部调用脚本
可以从任何其他项目调用，会自动切换到 index-tts 目录并激活 venv。

---

## 使用方法

### 方法一：在 index-tts 项目内使用

```bash
# 直接传入文本
./run_tts.sh -s examples/lbw.m4a -t "你好，世界！" -o output.wav

# 从文件读取文本
./run_tts.sh -s examples/lbw.m4a -f input.txt -o output.wav
```

### 方法二：从其他项目调用

**步骤 1: 配置脚本**

编辑 `call_tts.sh`，修改 `INDEX_TTS_DIR` 变量为你的 index-tts 项目路径：

```bash
INDEX_TTS_DIR="/Users/jiachengliu/Documents/index-tts"
```

**步骤 2: 复制或链接脚本到你的项目**

选项 A - 复制脚本：
```bash
cp /Users/jiachengliu/Documents/index-tts/call_tts.sh /path/to/your/project/
```

选项 B - 创建符号链接：
```bash
ln -s /Users/jiachengliu/Documents/index-tts/call_tts.sh /path/to/your/project/call_tts.sh
```

**步骤 3: 在你的项目中使用**

```bash
cd /path/to/your/project

# 使用绝对路径
./call_tts.sh /Users/jiachengliu/Documents/index-tts/examples/lbw.m4a "你好" output.wav

# 使用相对路径（speaker 音频、输出文件都相对于当前目录）
./call_tts.sh ../audio/speaker.m4a "测试文本" ./output/result.wav

# 从文件读取文本
./call_tts.sh speaker.m4a output.wav --file input.txt
```

---

## 参数说明

### 必需参数

- **speaker_audio**: 说话人音频提示文件路径
- **text**: 要转换的文本内容（与 --file 二选一）
- **output_path**: 输出音频文件路径

### 可选参数

- `-f, --file <file>`: 从文件读取文本内容（与直接传入文本二选一）

---

## 示例场景

### 场景 1: 批量生成语音

```bash
#!/bin/bash
# batch_tts.sh - 在你的项目中

for text_file in texts/*.txt; do
    filename=$(basename "$text_file" .txt)
    ./call_tts.sh speaker.m4a "output/${filename}.wav" --file "$text_file"
    echo "生成完成: output/${filename}.wav"
done
```

### 场景 2: 从 Python 脚本调用

```python
# your_script.py - 在你的项目中
import subprocess

def generate_speech(speaker_audio, text, output_path):
    result = subprocess.run(
        ['./call_tts.sh', speaker_audio, text, output_path],
        capture_output=True,
        text=True
    )
    return result.returncode == 0

# 使用
success = generate_speech(
    'examples/speaker.m4a',
    '你好，世界！',
    'output.wav'
)

if success:
    print('语音生成成功')
else:
    print('语音生成失败')
```

### 场景 3: 在 Node.js 中调用

```javascript
// your_script.js - 在你的项目中
const { exec } = require('child_process');

function generateSpeech(speakerAudio, text, outputPath) {
    return new Promise((resolve, reject) => {
        const cmd = `./call_tts.sh "${speakerAudio}" "${text}" "${outputPath}"`;
        
        exec(cmd, (error, stdout, stderr) => {
            if (error) {
                console.error(stderr);
                reject(error);
            } else {
                console.log(stdout);
                resolve(true);
            }
        });
    });
}

// 使用
generateSpeech('examples/speaker.m4a', '你好，世界！', 'output.wav')
    .then(() => console.log('语音生成成功'))
    .catch(err => console.error('语音生成失败:', err));
```

---

## 故障排查

### 错误: 找不到虚拟环境

确保在 index-tts 项目中已创建虚拟环境：

```bash
cd /Users/jiachengliu/Documents/index-tts
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt  # 如果有 requirements.txt
```

### 错误: 找不到项目目录

检查 `call_tts.sh` 中的 `INDEX_TTS_DIR` 路径是否正确。

### 权限错误

确保脚本有执行权限：

```bash
chmod +x call_tts.sh
chmod +x run_tts.sh
```

---

## 技术细节

### 路径处理

- 脚本会自动处理相对路径和绝对路径
- 相对路径相对于**调用脚本时的当前目录**
- 内部会自动切换到 index-tts 目录以正确加载模型

### 环境管理

- 自动激活和退出虚拟环境
- 保持调用者的工作目录不变
- 正确传递退出码（0=成功，1=失败）

### 兼容性

- 支持 bash 和 zsh
- 在 macOS 和 Linux 上测试通过
