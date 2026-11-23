#!/usr/bin/env python3
"""
테스트용 카드 데이터 묶음 만들기 (내부 테스트 배포용. 1.0.0 정식 릴리즈 전까지 WXCore_CardDB에는 올리지 않는다)

  python tools/test_bundle.py

만드는 것 (레포 최상단, git에 올리지 않는다):
  carddb_test/        wixoss.db · script/ · formats/ · icons/ · pics/<cid>.jpg·<cid>_<idx>.jpg (DB에 든 카드의 모든 판본)
  carddb_test.zip     위 폴더를 묶은 것. 테스터는 클라이언트 폴더(wx_frame.exe 옆)에 풀면 된다

순서: python tools/build_db.py --decks → python tools/copy_pics.py → python tools/test_bundle.py
덱을 넣을 때마다 다시 만든다(docs/progress.md 「카드 넣기」).
"""
import shutil
import sqlite3
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "carddb_test"
ZIP = ROOT / "carddb_test.zip"


def main():
    db_path = ROOT / "wixoss.db"
    db = sqlite3.connect(f"file:{db_path.as_posix()}?mode=ro", uri=True)
    prints = db.execute("SELECT cid, idx FROM prints ORDER BY cid, idx").fetchall()
    db.close()

    if OUT.exists():
        shutil.rmtree(OUT)
    (OUT / "pics").mkdir(parents=True)
    shutil.copyfile(db_path, OUT / "wixoss.db")
    shutil.copytree(ROOT / "script", OUT / "script")
    shutil.copytree(ROOT / "formats", OUT / "formats")
    if (ROOT / "icons" / "icons.json").exists():
        shutil.copytree(ROOT / "icons", OUT / "icons")
    missing = []
    for cid, idx in prints:
        src = ROOT / "pics" / (f"{cid}.jpg" if idx == 1 else f"{cid}_{idx}.jpg")
        if src.exists():
            shutil.copyfile(src, OUT / "pics" / src.name)
        else:
            missing.append(f"{cid}_{idx}")

    if ZIP.exists():
        ZIP.unlink()
    with zipfile.ZipFile(ZIP, "w", zipfile.ZIP_DEFLATED) as z:
        for f in sorted(OUT.rglob("*")):
            if f.is_file():
                z.write(f, f.relative_to(OUT).as_posix())

    n_script = len(list((OUT / "script").glob("*.lua")))
    n_cards = len({cid for cid, _ in prints})
    print(f"카드 {n_cards}종, 스크립트 {n_script}개, 그림 {len(prints) - len(missing)}장(판본 {len(prints)}장) -> {OUT.name}/, {ZIP.name}")
    if missing:
        print(f"그림 없음 {len(missing)}장(python tools/copy_pics.py): {missing[:20]}")


if __name__ == "__main__":
    main()
