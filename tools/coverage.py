#!/usr/bin/env python3
"""
카드 스크립트 진행도: 공식 카드 중 능력이 있는 카드가 몇 종 스크립트를 가졌는가

  python tools/coverage.py [아카이브 폴더]
    아카이브 폴더 기본값: D:/Claude Workspace/WixossArchive (cards.json을 읽기만 한다)

- 카드 1종 = cid(tools/cid_map.json). 덱에 넣지 않는 토큰·코인·순수 크래프트는 세지 않는다
- 능력 있음 = 어느 인쇄본이든 카드 텍스트(능력·라이프 버스트)가 있다. 능력 없는 카드는 스크립트가 필요 없다
- 완료 = script/c<cid>.lua가 있다
docs/progress.md 「카드 넣기」의 진행도 줄을 덱을 넣을 때마다 이 숫자로 갱신한다.
"""
import json
import re
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ARCHIVE = Path(sys.argv[1] if len(sys.argv) > 1 else r"D:\Claude Workspace\WixossArchive")


def main():
    cards = json.loads((ARCHIVE / "cards.json").read_text(encoding="utf-8"))
    cards = cards if isinstance(cards, list) else list(cards.values())
    nos = json.loads((ROOT / "tools" / "card_nos.json").read_text(encoding="utf-8"))
    kinds, has_text = {}, defaultdict(bool)
    for c in cards:
        no = c.get("card_no")
        if no not in nos:
            continue
        cid = nos[no][0]
        kinds[cid] = c["data"].get("カード種類", "")
        has_text[cid] |= any(s.strip() for s in c.get("skills") or [])
    skip = re.compile(r"トークン|コイン")
    deck_cids = [cid for cid, k in kinds.items() if not skip.search(k) and k.replace("\n", "") not in ("クラフト", "-")]
    scripts = {int(p.stem[1:]) for p in (ROOT / "script").glob("c*.lua") if p.stem[1:].isdigit()}
    need = [cid for cid in deck_cids if has_text[cid]]
    done = [cid for cid in need if cid in scripts]
    print(f"카드 {len(deck_cids)}종 중 능력 있음 {len(need)}종, 스크립트 {len(done)}종 ({len(done) / len(need) * 100:.1f}%), "
          f"능력 없음 {len(deck_cids) - len(need)}종")


if __name__ == "__main__":
    main()
