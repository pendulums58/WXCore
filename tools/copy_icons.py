#!/usr/bin/env python3
"""
아카이브의 공식 텍스트 아이콘 -> <출력 폴더>/icons/ (그림 + icons.json 매핑)

  python tools/copy_icons.py [아카이브 폴더] [출력 폴더]
    아카이브 폴더 기본값: D:/Claude Workspace/WixossArchive (guides/mirror의 icon_txt_*.png를 읽기만 한다)
    출력 폴더 기본값: 레포 최상단 (icons/는 git에 올리지 않는다. 카드 DB 저장소 묶음에는 넣는다)

- icons.json: {"토큰": "그림 파일"}. 프레임이 데이터 폴더마다 읽고 뒤가 덮는다(오리카 팩은 자기 icons/를 둔다)
- 매핑에 없는 토큰(《白×0》·카드 이름 인용 등)은 원문 그대로 보인다
"""
import json
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ARCHIVE = Path(sys.argv[1] if len(sys.argv) > 1 else r"D:\Claude Workspace\WixossArchive")
OUT = (Path(sys.argv[2]) if len(sys.argv) > 2 else ROOT) / "icons"
SRC = ARCHIVE / "guides" / "mirror" / "products" / "wixoss" / "img" / "card" / "icon"

# 토큰 -> 아카이브 그림 이름(icon_txt_<이름>.png). 색은 텍스트용 평면 아이콘(white), 보석 모양(white2)은 쓰지 않는다
ICONS = {
    "【出】": "arrival", "【自】": "auto", "【起】": "starting", "【常】": "regular",
    "【チーム】": "team", "【チーム出】": "arrival_team", "【チーム自】": "auto_team",
    "【チーム起】": "starting_team", "【チーム常】": "regular_team", "【ドリームチーム】": "dreamteam",
    "【ライフバースト】": "burst",
    "《白》": "white", "《赤》": "red", "《青》": "blue", "《緑》": "green", "《黒》": "black", "《無》": "null",
    "《コインアイコン》": "coin",
    "《メインフェイズアイコン》": "phase_main", "《アタックフェイズアイコン》": "phase_attack",
    "《スペルカットインアイコン》": "phase_spell",
    "《ターン１回》": "turn_01",
}


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    mapping, missing = {"_note": "토큰 -> 그림 파일(이 폴더 기준). tools/copy_icons.py로 만든다"}, []
    for token, name in ICONS.items():
        src = SRC / f"icon_txt_{name}.png"
        if not src.exists():
            missing.append(f"{token} ({src.name})")
            continue
        shutil.copyfile(src, OUT / f"{name}.png")
        mapping[token] = f"{name}.png"
    (OUT / "icons.json").write_text(json.dumps(mapping, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"아이콘 {len(mapping) - 1}개 -> {OUT}" + (f", 그림 없음: {missing}" if missing else ""))


if __name__ == "__main__":
    main()
