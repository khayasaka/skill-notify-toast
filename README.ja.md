[English](README.md)

# notify スキル

Claude Code・GitHub Copilot CLI・Cursor で使えるクロスプラットフォームのトースト通知スキルです。

実行中の AI ツールと OS 環境を自動判定し、対応するアイコン付きでトースト通知を表示します。

## 対応環境

| 環境 | 通知 | アイコン |
|------|:----:|:--------:|
| Windows (Git Bash) | ✅ | ✅ |
| WSL | ✅ | ✅ |
| macOS | ✅ | — |
| Linux | ✅ | ✅ |

> **macOS**: `osascript` はカスタムアイコンに非対応です。ターミナルアプリのシステムアイコンが表示されます。

## 必要なもの

| 環境 | 必要なもの |
|------|-----------|
| Windows / WSL | [BurntToast](https://github.com/Windos/BurntToast) — 初回実行時に自動インストール |
| Windows / WSL（任意） | [node-notifier](https://www.npmjs.com/package/node-notifier) — snoretoast による高速通知が有効になる |
| Linux | `notify-send` — パッケージマネージャーでインストール |
| macOS | 不要 |

### node-notifier による高速通知（Windows / WSL）

[node-notifier](https://www.npmjs.com/package/node-notifier) をグローバルインストールすると、[snoretoast](https://github.com/KDE/snoretoast) 経由での通知が有効になります。
snoretoast はノンブロッキングなネイティブ実行ファイルのため、BurntToast より大幅に高速です。

```bash
npm install -g node-notifier
```

- snoretoast のパスは初回実行後に `.snoretoast_cache` にキャッシュされ、npm の起動コストを排除します。
- node-notifier が未インストールの場合は BurntToast に自動フォールバックします。
- **WSL の場合**: WSL 側の node-notifier は使用しません。WSL 側の EXE は `\\wsl.localhost\...` という UNC パスになり、Windows のセキュリティポリシーでブロックされる可能性があるためです。代わりに `cmd.exe` 経由で **Windows 側の npm** を参照します。Windows 側に node-notifier がインストールされていれば WSL でも高速通知が有効になります。

## インストール

`.claude/skills/` ディレクトリにクローンしてください。

```bash
git clone https://github.com/khayasaka/skill-notify-toast.git ~/.claude/skills/notify
```

## アイコンの設定（任意）

`assets/` ディレクトリに PNG ファイルを置くと、ツールごとのアイコンが通知に表示されます。
ファイルが存在しない場合はアイコンなしで通知されます。

| ファイル名 | 使用されるツール |
|-----------|----------------|
| `claude.png` | Claude Code |
| `cursor.png` | Cursor |
| `copilot.png` | GitHub Copilot CLI |

ライセンスの都合上、アイコンはリポジトリに含まれていません。
個人利用の場合は [UXWing](https://uxwing.com/) などからダウンロードできます。

> `assets/` ディレクトリは `.gitignore` でバージョン管理から除外されています。

## 使い方

```
/notify [タイトル] [メッセージ]
```

## 動作の仕組み

スキルは2段階で環境を判定します。

**1. AI ツールの判定**

| 環境変数 | ツール |
|----------|--------|
| `CLAUDECODE=1` | Claude Code |
| `CURSOR_AGENT=1` | Cursor |
| どちらもない | GitHub Copilot CLI |

> 注意: Cursor は既知のバグにより `CURSOR_AGENT=1` が設定されないことがあります。その場合は Copilot のアイコンにフォールバックします。

**2. OS 環境の判定**

| 条件 | 環境 |
|------|------|
| `WSL_DISTRO_NAME` が設定されている、または `/proc/version` に `microsoft` を含む | WSL |
| `uname -s` が `Darwin` | macOS |
| `uname -s` が `MINGW` / `MSYS` で始まる、または `OS=Windows_NT` | Windows (Git Bash) |
| それ以外 | Linux |

## ライセンス

[MIT](LICENSE) © khayasaka@gmail.com
