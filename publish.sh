#!/bin/bash
export PATH="/home/landslide/.nvm/versions/node/v22.22.3/bin:$PATH"
# Obsidian 볼트를 Quartz content에 동기화하고 GitHub에 push합니다.
# 실행: ./publish.sh
# 선택적 커밋 메시지: ./publish.sh "내 노트 업데이트"

OBSIDIAN_VAULT="/home/landslide/Insync/minki.seo@gmail.com/Google Drive/GoogleDrive_Linux/Obsidian Valut/SMK2026"
QUARTZ_DIR="$(cd "$(dirname "$0")" && pwd)"
CONTENT_DIR="$QUARTZ_DIR/content"
MESSAGE="${1:-Quartz sync: $(date '+%B %d, %Y, %I:%M %p')}"

echo "Obsidian → content 동기화 중..."
python3 - << PYEOF
import shutil, os
from pathlib import Path

src = Path("$OBSIDIAN_VAULT")
dst = Path("$CONTENT_DIR")

# content 디렉토리 없으면 생성
dst.mkdir(parents=True, exist_ok=True)

# 삭제된 파일 반영: 기존 content 삭제 후 재복사
for item in dst.iterdir():
    if item.name.startswith('.'):
        continue
    if item.is_dir():
        shutil.rmtree(item)
    else:
        item.unlink()

ignore = shutil.ignore_patterns('.obsidian', '.trash', '*.canvas')
shutil.copytree(src, dst, ignore=ignore, dirs_exist_ok=True)
print(f"  {sum(1 for _ in dst.rglob('*') if _.is_file())} 파일 동기화됨")

index_md = dst / "index.md"
if not index_md.exists():
    index_md.write_text("---\ntitle: Home\n---\n\n# 환영합니다\n")
    print("  index.md 자동 생성됨")
PYEOF

echo "GitHub에 push 중..."
cd "$QUARTZ_DIR" && npx quartz sync --message "$MESSAGE"
