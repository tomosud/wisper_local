# Whisper Local - ローカルGPU対応音声文字起こしツール

ローカル環境でGPUを使用してWhisperによる音声文字起こしを行うツールです。
音声・動画ファイルをドラッグ&ドロップするだけで、自動的にテキストファイルを生成します。

## 特徴

- ✅ **完全ローカル実行** - インターネット接続不要で文字起こし可能
- ✅ **GPU対応** - CUDA対応GPUで高速処理
- ✅ **簡単セットアップ** - Pythonのインストール不要、batファイルで自動セットアップ
- ✅ **ドラッグ&ドロップ対応** - 音声ファイルをドロップするだけで実行
- ✅ **多様なフォーマット対応** - MP3, WAV, M4A, MP4, MOV, AVI, FLV, WEBM

## 必要な環境

- Windows 10/11 (64bit)
- NVIDIA GPU (CUDA対応) ※推奨
- インターネット接続 (初回セットアップ時のみ)

## インストール方法

### 1. プロジェクトのダウンロード

**配布ファイルから:**

1. `haihu`フォルダを任意の場所に配置
2. `haihu\download_project.bat` をダブルクリック
3. プロジェクトファイルが自動的にダウンロード・展開されます

### 2. セットアップ

1. `setup_gpu.bat` をダブルクリック
2. 以下が自動的に実行されます:
   - Python埋め込み版のダウンロード
   - PyTorch (CUDA対応) のインストール
   - Whisperのインストール
   - FFmpegのダウンロード

※初回セットアップには10-20分程度かかります

## 使い方

### 音声ファイルをテキスト化

1. 音声ファイル (MP3, WAV, M4A等) を `make_txt.bat` にドラッグ&ドロップ
2. 処理が完了すると、同じフォルダに `.txt` ファイルが生成されます

**対応フォーマット:**
- 音声: MP3, WAV, M4A
- 動画: MP4, MOV, AVI, FLV, WEBM

### 複数ファイルの一括処理

複数のファイルを同時に `make_txt.bat` にドロップすることで、一括処理が可能です。

## フォルダ構成

```
wisper_local/
├── haihu/
│   └── download_project.bat  # プロジェクトダウンロード用 (配布ファイル)
├── python/                    # Python埋め込み版 (自動生成)
├── setup_gpu.bat              # セットアップスクリプト
├── make_txt.bat               # 実行用スクリプト (ドラッグ&ドロップ)
├── whisper_transcriber.py     # メインプログラム
├── requirements.txt           # 依存パッケージリスト
├── ffmpeg.exe                 # FFmpeg (自動ダウンロード)
└── README.md                  # このファイル
```

## トラブルシューティング

### GPUが認識されない

- NVIDIA GPUドライバーが最新か確認してください
- CUDAが正しくインストールされているか確認してください

### エラーが発生する

1. `setup_gpu.bat` を再実行してください
2. `python` フォルダと `ffmpeg.exe` を削除してから再セットアップ

### 処理が遅い

- GPUが認識されていない可能性があります
- CPUでも動作しますが、処理時間が長くなります

## ライセンス

このプロジェクトは以下のオープンソースソフトウェアを使用しています:

- [OpenAI Whisper](https://github.com/openai/whisper) - MIT License
- [PyTorch](https://pytorch.org/) - BSD License
- [FFmpeg](https://ffmpeg.org/) - GPL License

## クレジット

Generated with Claude Code
