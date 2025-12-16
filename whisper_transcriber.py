import whisper
import subprocess
import os
import torch
import tempfile
import sys
from pathlib import Path

if len(sys.argv) < 2:
    print("エラー: ファイルが指定されていません")
    print("使用方法: python whisper_transcriber.py <input_file> [<input_file2> ...]")
    sys.exit(1)

input_files = []
supported_extensions = {'.mp3', '.wav', '.m4a', '.mp4', '.mov', '.avi', '.flv', '.webm'}

for arg in sys.argv[1:]:
    input_path = Path(arg)
    if not input_path.exists():
        print(f"⚠️ ファイルが見つかりませんのでスキップします: {arg}")
        continue
    if input_path.suffix.lower() not in supported_extensions:
        print(f"⚠️ 対応していないファイル形式のためスキップします: {input_path.suffix} ({arg})")
        continue
    input_files.append(input_path)

if not input_files:
    print("エラー: 処理可能なファイルがありません")
    print(f"対応形式: {', '.join(sorted(supported_extensions))}")
    sys.exit(1)

print(f"処理対象ファイル数: {len(input_files)}")
for i, file in enumerate(input_files, 1):
    print(f"  {i}. {file}")
print()

device = "cuda" if torch.cuda.is_available() else "cpu"
print(f"使用デバイス: {device}")
if device == "cuda":
    print(f"GPU: {torch.cuda.get_device_name(0)}")

def get_ffmpeg_path():
    try:
        subprocess.run(["ffmpeg", "-version"], capture_output=True, check=True)
        return "ffmpeg"
    except (subprocess.CalledProcessError, FileNotFoundError):
        local_ffmpeg = Path(__file__).parent / "ffmpeg.exe"
        if local_ffmpeg.exists():
            return str(local_ffmpeg)
        else:
            raise FileNotFoundError("エラー: ffmpeg.exeが見つかりません。PATHまたは実行フォルダに配置してください")

# FFmpegとWhisperモデルを事前に準備
try:
    ffmpeg_path = get_ffmpeg_path()
    print("Whisperモデル読み込み中...")
    model = whisper.load_model("turbo", device=device)
    language = os.getenv("WHISPER_LANGUAGE", "ja")
    print(f"言語設定: {language}")
    print()
except Exception as e:
    print(f"エラー: 初期化に失敗しました: {e}")
    sys.exit(1)

success_count = 0
error_count = 0

# 各ファイルを処理
for i, input_file in enumerate(input_files, 1):
    print(f"=" * 60)
    print(f"ファイル {i}/{len(input_files)}: {input_file.name}")
    print(f"=" * 60)

    output_txt = input_file.with_suffix('.txt')
    converted_wav = tempfile.mktemp(suffix=".wav")

    try:
        print(f"入力ファイル: {input_file}")
        print(f"出力TXTファイル: {output_txt}")

        print("音声ファイルを変換中...")
        subprocess.run([
            ffmpeg_path, "-y", "-i", str(input_file),
            "-vn", "-acodec", "pcm_s16le", "-ar", "16000", "-ac", "1", converted_wav
        ], check=True, capture_output=True)

        print("Whisperで文字起こし実行中...")
        result = model.transcribe(converted_wav, language=language, task="transcribe", verbose=False)

        print(f"TXTファイルを保存中: {output_txt}")
        with open(output_txt, "w", encoding="utf-8") as f:
            # 冒頭の指示文
            header = """入力されたテキストを要約してください。内容を省略せずに。
内容は簡潔に箇条書きで記してください。

Slackへ貼り付けたいのでマークダウン形式ではなく、中黒（・）を利用して見出しや箇条書きを作成して。
見出しの後に続く項目は全角スペースでインデントしてください。

トピックごとに整理し、トピック名で見出しをつけて分類してください。

インターネットなどから補足情報を取得して付与せず、入力されたテキストの内容だけで構成してください。

また、要約の先頭には何もテキストを挿入しないこと。


では、以下を要約して。
-------

"""
            f.write(header)
            f.write(result["text"].strip())

        print(f"✅ TXTファイルを保存しました: {output_txt}")

        success_count += 1

    except subprocess.CalledProcessError as e:
        print(f"❌ エラー: 音声変換に失敗しました: {e}")
        error_count += 1
    except Exception as e:
        print(f"❌ エラー: 処理中に問題が発生しました: {e}")
        error_count += 1
    finally:
        # 一時ファイルのクリーンアップ
        try:
            os.remove(converted_wav)
        except FileNotFoundError:
            pass

    print()

print(f"=" * 60)
print(f"処理完了: 成功 {success_count}件 / エラー {error_count}件 / 合計 {len(input_files)}件")
print(f"=" * 60)
