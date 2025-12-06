import argparse
import sys
from indextts.infer_v2 import IndexTTS2


def text_to_speech(spk_audio_prompt: str, text: str, output_path: str) -> bool:
    """
    使用 IndexTTS2 模型将文本转换为语音

    Args:
        spk_audio_prompt: 说话人音频提示文件路径
        text: 要转换的文本内容
        output_path: 输出音频文件路径

    Returns:
        bool: 转换成功返回 True，失败返回 False
    """
    try:
        tts = IndexTTS2(
            cfg_path="checkpoints/config.yaml",
            model_dir="checkpoints",
            use_fp16=False,
            use_cuda_kernel=False,
            use_deepspeed=False,
        )

        tts.infer(
            spk_audio_prompt=spk_audio_prompt,
            text=text,
            output_path=output_path,
            emo_alpha=0.6,
            use_emo_text=True,
            use_random=False,
            verbose=True,
        )

        return True
    except Exception as e:
        print(f"转换失败: {str(e)}")
        return False


def main():
    """命令行入口函数"""
    parser = argparse.ArgumentParser(
        description="使用 IndexTTS2 模型将文本转换为语音",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例用法:
  source ./venv/bin/activate
  uv run main.py -s examples/lbw.m4a -t "你好，世界！" -o output.wav
  uv run main.py --spk examples/lbw.m4a --text "测试文本" --output result.wav
  uv run main.py -s examples/lbw.m4a -f input.txt -o output.wav
        """,
    )

    parser.add_argument(
        "-s",
        "--spk",
        dest="spk_audio_prompt",
        required=True,
        help="说话人音频提示文件路径",
    )

    parser.add_argument("-t", "--text", dest="text", help="要转换的文本内容")

    parser.add_argument(
        "-f",
        "--file",
        dest="text_file",
        help="包含要转换文本的文件路径（与 --text 二选一）",
    )

    parser.add_argument(
        "-o", "--output", dest="output_path", required=True, help="输出音频文件路径"
    )

    args = parser.parse_args()

    # 检查文本输入
    if not args.text and not args.text_file:
        parser.error("必须提供 --text 或 --file 参数之一")
        sys.exit(1)

    if args.text and args.text_file:
        parser.error("--text 和 --file 参数不能同时使用")
        sys.exit(1)

    # 获取文本内容
    if args.text_file:
        try:
            with open(args.text_file, "r", encoding="utf-8") as f:
                text = f.read().strip()
        except Exception as e:
            print(f"读取文件失败: {str(e)}", file=sys.stderr)
            sys.exit(1)
    else:
        text = args.text

    # 执行转换
    print(f"正在转换语音...")
    print(f"  音频提示: {args.spk_audio_prompt}")
    print(f"  文本长度: {len(text)} 字符")
    print(f"  输出路径: {args.output_path}")

    success = text_to_speech(
        spk_audio_prompt=args.spk_audio_prompt, text=text, output_path=args.output_path
    )

    if success:
        print("✓ 语音生成成功！")
        sys.exit(0)
    else:
        print("✗ 语音生成失败！", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    # 如果没有命令行参数，运行示例代码
    if len(sys.argv) == 1:
        print("运行示例代码...\n")
        # 示例用法
        sample_text = "8号麦序！兄弟们全体起立！我这里就是一张铁铁的闭眼好人牌。我卢本伟没开天眼啊，前面几位的逻辑没毛病，我都认。但是看到这个2号我真的想笑，我甚至是有点想笑。女巫都没跳，大家眼睛都闭着呢，你2号凭什么就在那儿言之凿凿说5号是银水金水？你是神仙吗？你开了透视吗？你在赣神魔？这波只有一种解释，你2号就是狼，你开了天眼知道昨晚刀口！要么你就是在强行带节奏，硬要把这个4号捧上去。你这种操作简直就是伞兵一号，就是在自爆给4号拉仇恨，你懂不懂啊？再看这个6号，哇这波操作太秀了。4号给他警徽流，他反手就是一个超级加倍，直接打烂你2号和4号的脸。兄弟们你们用脑子想一想，如果6号是狼，他为什么要这么刚？他是不是傻？他顺势打个倒钩或者划水不香吗？非要跟拿警徽的4号硬刚？所以6号这波我实名认证绝对的好人。如果6号是狼，我当场把这个麦克风吃掉！既然2号这种聊爆的牌在拿命保4号，那4号是个什么东西？4号就是那张悍跳狼！12号敢在警上直接查杀警长，这波力度我给满分。给4号倒一杯卡布奇诺，让他走得体面一点。今天就站边12号，全票打飞这个4号！难受啊4号！过。"

        success = text_to_speech(
            spk_audio_prompt="examples/lbw.m4a", text=sample_text, output_path="gen.wav"
        )

        if success:
            print("语音生成成功！")
        else:
            print("语音生成失败！")
    else:
        # 运行命令行模式
        main()
