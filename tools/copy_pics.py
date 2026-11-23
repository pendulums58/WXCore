#!/usr/bin/env python3
"""
아카이브 카드 이미지 -> pics/<cid>.jpg, pics/<cid>_<idx>.jpg 복사 (YGOPro식 이름 + 판본)

  python tools/copy_pics.py [아카이브 폴더] [출력 폴더]
    아카이브 폴더 기본값: D:/Claude Workspace/WixossArchive (images/를 읽기만 한다)
    출력 폴더 기본값: pics (레포 최상위, git에 올리지 않는다)

- 판본(prints)마다 한 장: idx 1은 <cid>.jpg, 그 밖은 <cid>_<idx>.jpg(설계: 이미지 파일).
- 아카이브에 판본 그림이 없으면 그 파일은 만들지 않는다(프레임은 기본 그림을 쓴다).
- 이미 있는 파일은 건너뛴다(크기가 같으면). 다시 돌려도 된다.
"""
import shutil
import sqlite3
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ARCHIVE = Path(sys.argv[1] if len(sys.argv) > 1 else r"D:\Claude Workspace\WixossArchive")
OUT = Path(sys.argv[2]) if len(sys.argv) > 2 else ROOT / "pics"
DB = ROOT / "wixoss.db"


def local_path(url):
    # https://www.takaratomy.co.jp/products/wixoss/img/card/WXDi/WXDi-D01-001.jpg -> images/WXDi/WXDi-D01-001.jpg
    if not url or "/img/card/" not in url:
        return None
    return ARCHIVE / "images" / url.split("/img/card/", 1)[1]


def main():
    db = sqlite3.connect(f"file:{DB.as_posix()}?mode=ro", uri=True)
    rows = db.execute("SELECT cid, idx, image FROM prints ORDER BY cid, idx").fetchall()
    OUT.mkdir(parents=True, exist_ok=True)
    have, copied, missing = 0, 0, []
    for cid, idx, url in rows:
        src = local_path(url)
        if not src or not src.exists():
            missing.append(f"{cid}_{idx}")
            continue
        have += 1
        dst = OUT / (f"{cid}.jpg" if idx == 1 else f"{cid}_{idx}.jpg")
        if dst.exists() and dst.stat().st_size == src.stat().st_size:
            continue
        shutil.copyfile(src, dst)
        copied += 1
    print(f"판본 {len(rows)}장 중 그림 {have}장, 새로 복사 {copied}장, 그림 없음 {len(missing)}장 {missing[:20]}")


if __name__ == "__main__":
    main()
