#!/usr/bin/env python3
"""
아카이브 카드 이미지 -> pics/<cid>.jpg 복사 (YGOPro식 이름)

  python tools/copy_pics.py [아카이브 폴더] [출력 폴더]
    아카이브 폴더 기본값: D:/Claude Workspace/WixossArchive (images/를 읽기만 한다)
    출력 폴더 기본값: pics (레포 최상위, git에 올리지 않는다)

- cid마다 prints의 기본 일러스트(idx가 가장 작은 것)부터 찾아, 아카이브에 파일이 있는 첫 장을 쓴다.
- 이미 있는 파일은 건너뛴다(크기가 같으면). 다시 돌려도 된다.
"""
import shutil
import sqlite3
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ARCHIVE = Path(sys.argv[1] if len(sys.argv) > 1 else r"D:\Claude Workspace\WixossArchive")
OUT = Path(sys.argv[2]) if len(sys.argv) > 2 else ROOT / "pics"
DB = ROOT / "expansions" / "official" / "wixoss.db"


def local_path(url):
    # https://www.takaratomy.co.jp/products/wixoss/img/card/WXDi/WXDi-D01-001.jpg -> images/WXDi/WXDi-D01-001.jpg
    if not url or "/img/card/" not in url:
        return None
    return ARCHIVE / "images" / url.split("/img/card/", 1)[1]


def main():
    db = sqlite3.connect(f"file:{DB.as_posix()}?mode=ro", uri=True)
    rows = db.execute("SELECT cid, image FROM prints ORDER BY cid, idx").fetchall()
    OUT.mkdir(parents=True, exist_ok=True)
    done, copied, missing = set(), 0, []
    for cid, url in rows:
        if cid in done:
            continue
        src = local_path(url)
        if not src or not src.exists():
            continue
        done.add(cid)
        dst = OUT / f"{cid}.jpg"
        if dst.exists() and dst.stat().st_size == src.stat().st_size:
            continue
        shutil.copyfile(src, dst)
        copied += 1
    for cid in sorted({r[0] for r in rows} - done):
        missing.append(cid)
    print(f"카드 {len(done)}종, 새로 복사 {copied}장, 이미지 없음 {len(missing)}종 {missing[:20]}")


if __name__ == "__main__":
    main()
