#!/usr/bin/env python3
"""
cards.json(공식 크롤링 결과) -> wixoss.db(SQLite) 변환

  python tools/build_db.py [아카이브 폴더] [출력 폴더] [--decks]
    --decks: decks/*.json에 든 카드와 스크립트가 있는 카드만 DB에 넣는다(내부 테스트용). cid_map.json은 전체 기준 그대로
    아카이브 폴더 기본값: D:/Claude Workspace/WixossArchive (cards.json을 읽기만 한다)
    출력 폴더 기본값: 레포 최상단 (wixoss.db. YGOPro의 cards.cdb 자리)
    cid_map.json·card_nos.json·texts_ko.json·build_report.txt는 tools/

- cards  : 룰상 카드 1종 = 스크립트 1개 (cid). 종류·사용 타이밍·포맷은 비트
- prints : 카드(cid)별 판본 (재록·프로모·패러렐·다른 일러). 키 = (cid, idx). 이미지·플레이버
- cards.alias : 이름이 같은 다른 카드(색·레벨이 달라 cid가 갈린 것)의 대표 cid
- classes : 系統·種族·루리그 타입의 이름 ↔ ID. 공식 표는 tools/classes.json(표기 흔들림·데이터 오류 수정 포함)
- card_meta : 오리카 제작 정보(공식 카드는 비어 있음)
- texts  : 언어별 이름·읽기 (공식은 ja, 번역은 ko)
- strings : 효과 설명 문자열 (kind 0 능력 줄, 1 str(모드 ①② 등), 2 라이프 버스트). 설계: 「효과 설명 문자열」.
  카드 본문·LB 텍스트도 이걸 이어 붙여 보여 준다
  모드 말고 따로 넣는 str(「AするかBする」의 선택지 등)은 tools/strings.json: {cid: {"ja": [...], "ko": [...]}}
- DB에는 카드 번호가 없다. 데이터·덱·번역 파일은 cid로 가리킨다
- cid_map.json : 이름 키 -> cid 고정 매핑. 다시 돌려도 번호가 바뀌지 않는다.
- card_nos.json : 카드 번호 -> [cid, idx]. 케이스·도구용(배포하지 않는다)
- build_report.txt : 같은 이름인데 텍스트·수치가 다른 묶음, 해석 못 한 값 목록
"""
import json
import re
import shutil
import sqlite3
import sys
import tempfile
import unicodedata
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ARGS = [a for a in sys.argv[1:] if not a.startswith("--")]
ONLY_DECKS = "--decks" in sys.argv[1:]
ARCHIVE = Path(ARGS[0] if len(ARGS) > 0 else r"D:\Claude Workspace\WixossArchive")
HERE = Path(ARGS[1]) if len(ARGS) > 1 else ROOT
TOOLS = ROOT / "tools"
SRC = ARCHIVE / "cards.json"
DST = HERE / "wixoss.db"
CID_MAP = TOOLS / "cid_map.json"
EXTRA_STRINGS = TOOLS / "strings.json"
CLASSES = TOOLS / "classes.json"
CARD_NOS = TOOLS / "card_nos.json"
REPORT = TOOLS / "build_report.txt"

OFFICIAL_CID_MAX = 999_999  # 오리카는 1,000,000부터

COLOR_BIT = {"白": 1, "赤": 2, "青": 4, "緑": 8, "黒": 16}
ENA_SYM = {"白": "W", "赤": "R", "青": "U", "緑": "G", "黒": "B", "無": "C"}
FORMAT_KEY, FORMAT_DIVA = 1, 2

report = defaultdict(list)


def nfkc(s):
    return unicodedata.normalize("NFKC", s or "")


def nil(v):
    v = (v or "").strip()
    return None if v in ("", "-") else v


def split_multi(v):
    """'シグニ\nクラフト', 'タマ/イオナ', '精像：天使/悪魔' -> 목록"""
    v = nil(v)
    if v is None:
        return []
    out = []
    for part in re.split(r"[\n／]|　(?=\S)", v):
        part = part.strip()
        if not part:
            continue
        if "/" in part:
            # '精像：天使/悪魔' -> ['精像：天使', '精像：悪魔']
            head, _, rest = part.rpartition("：")
            subs = (rest if head else part).split("/")
            out += [f"{head}：{s}" if head else s for s in subs]
        else:
            out.append(part)
    return out


CLASS_SYS, CLASS_RACE, CLASS_LRIG = 0, 1, 2  # classes.kind


class ClassTable:
    """tools/classes.json: 이름 -> ID. 표에 없는 이름은 빌드를 멈춘다(오타가 새 클래스가 되지 않게)"""

    def __init__(self, path):
        j = json.loads(path.read_text(encoding="utf-8"))
        self.rows = [(kind, r["id"], r["const"], r["ja"]) for kind, part in
                     ((CLASS_SYS, "sys"), (CLASS_RACE, "race"), (CLASS_LRIG, "lrig")) for r in j[part]]
        self.ids = {(kind, ja): i for kind, i, _, ja in self.rows}
        self.alias = j.get("alias", {})
        self.fix = j.get("fix", {})
        self.unknown = []

    def id(self, kind, name, no):
        name = self.alias.get(name.strip(), name.strip())
        i = self.ids.get((kind, name))
        if i is None:
            self.unknown.append(f"{no}: {('系統', '種族', '루리그 타입')[kind]} {name}")
        return i

    def raw(self, card):
        return self.fix.get(card["card_no"], card["data"].get("カードタイプ"))

    def signi(self, card):
        """'精像：天使/悪魔', '解放派\\n奏像：武勇', '精元' -> [[系統, 種族], ...] (콜론 없는 클래스는 種族 0)"""
        v, no, out = nil(self.raw(card)), card["card_no"], []
        for part in re.split(r"[\n／]", v or ""):
            part = part.strip()
            if not part:
                continue
            head, sep, rest = part.partition("：")
            s = self.id(CLASS_SYS, head, no)
            for r in rest.split("/") if sep else [None]:
                pair = [s, self.id(CLASS_RACE, r, no) if r is not None else 0]
                if None not in pair and pair not in out:
                    out.append(pair)
        return out

    def lrig(self, v, no, suffix=""):
        """'タマ/イオナ', 'ピルルク限定' -> [ID, ...]"""
        out = []
        for part in re.split(r"[\n／/]", nil(v) or ""):
            part = part.strip().removesuffix(suffix)
            if part and (i := self.id(CLASS_LRIG, part, no)) is not None and i not in out:
                out.append(i)
        return out


def to_int(v, field, no):
    v = nil(v)
    if v is None:
        return None
    v = nfkc(v)
    if v == "∞":
        return -1  # 무한대 표기
    if re.fullmatch(r"\d+", v):
        return int(v)
    report["해석 못 한 숫자"].append(f"{no} {field}={v}")
    return None


def parse_cost(v, no, field):
    """'《青》×１\n《無》×１' -> ena='{U}{C}', other={'coin':n}"""
    v = nil(v)
    if v is None:
        return None, {}
    ena, other = "", {}
    if re.search(r"\bor\b", v):
        # 'グロウコスト: 《白/赤/青/緑/黒》×５ or キー' 같은 대체 비용 -> 첫 부분만 해석, 원문 보존
        alt = v.split("or", 1)[1].strip()
        other["alt"] = alt
        v = v.split("or", 1)[0]
    for sym, cnt in re.findall(r"《([^》]+)》×\s*([0-9０-９]+)", v):
        n = int(nfkc(cnt))
        if "/" in sym and all(x in ENA_SYM for x in sym.split("/")):
            # 하이브리드: 《白/黒》 = 백 또는 흑 -> {W/B}
            ena += ("{" + "/".join(ENA_SYM[x] for x in sym.split("/")) + "}") * n
        elif sym in ENA_SYM:
            ena += ("{" + ENA_SYM[sym] + "}") * n
        elif sym in ("コイン", "コインアイコン"):
            other["coin"] = other.get("coin", 0) + n
        else:
            other[sym] = other.get(sym, 0) + n
            report["모르는 비용 기호"].append(f"{no} {field}: {sym}")
    leftover = re.sub(r"《[^》]+》×\s*[0-9０-９]+|\s", "", v)
    if leftover:
        report["비용 해석 잔여"].append(f"{no} {field}: {v}")
    return ena, other


TYPE_BIT = {"ルリグ": 1, "シグニ": 2, "アーツ": 4, "スペル": 8, "アシストルリグ": 16, "トークン": 32, "ピース": 64,
            "キー": 128, "レゾナ": 256, "クラフト": 512, "コイン": 1024, "リレー": 2048}  # wx::TYPE_*
TIMING_BIT = {"メインフェイズ": 1, "アタックフェイズ": 2, "スペルカットイン": 4}  # wx::TIMING_*


def type_bits(kinds, no):
    t = 0
    for k in kinds:
        if k in TYPE_BIT:
            t |= TYPE_BIT[k]
        else:
            report["모르는 カード種類"].append(f"{no} {k}")
    return t


def timing_bits(timings, no):
    t = 0
    for x in timings:
        if x in TIMING_BIT:
            t |= TIMING_BIT[x]
        else:
            report["모르는 使用タイミング"].append(f"{no} {x}")
    return t


def color_mask(v):
    v = nil(v)
    if v is None:
        return None
    m = 0
    for ch in v:
        m |= COLOR_BIT.get(ch, 0)
    return m  # 0 = 무색


def text_key(c):
    """같은 카드 판정용 텍스트 정규화 (표기 업데이트 차이는 어느 정도 흡수)"""
    t = nfkc("\n".join(c["skills"]))
    t = re.sub(r"[\s。、，,.・「」『』（）()]", "", t)
    return t


STR_ABILITY, STR_STR, STR_LB = 0, 1, 2
MAX_ABILITY, MAX_STR = 15, 16
MODE_MARK = "①②③④⑤⑥⑦⑧⑨"


def modes_of(text):
    """①~⑨에서 시작해 다음 번호나 줄바꿈 전까지(모드). 줄 맨 앞(스펠)이든 문장 중간(라이프 버스트)이든"""
    return [m.strip() for m in re.findall(f"[{MODE_MARK}][^{MODE_MARK}\n]*", text or "")]


def split_abilities(text):
    """카드 텍스트 -> (능력 줄 목록, str 목록)
    【…】(또는 《トラップアイコン》)로 시작하는 줄에서 새 능력. 나머지 줄(①②·괄호 주석·빈 줄)은 앞 능력에 붙는다.
    【使用条件】은 능력이 아니라 뒤 본문과 한 덩어리. 모드(①②)는 순서대로 str에도 넣는다"""
    abilities = []
    after_cond = False  # 바로 앞 줄이 【使用条件】이면 다음 줄은 새 능력이 아니다
    for line in (text or "").split("\n"):
        s = line.strip()
        if ((s.startswith("【") or s.startswith("《トラップアイコン》")) and not after_cond) or not abilities:
            abilities.append(line)
        else:
            abilities[-1] += "\n" + line
        if s:
            after_cond = s.startswith("【使用条件】")
    abilities = [a.strip("\n") for a in abilities if a.strip()]
    return abilities, modes_of(text)


def insert_strings(db, cid, lang, ability, life_burst, no, extra=None):
    abilities, modes = split_abilities(ability)
    strs = modes + modes_of(life_burst) + list(extra or [])  # 능력 본문의 모드 → 라이프 버스트의 모드 → 따로 넣은 것
    if len(abilities) > MAX_ABILITY:
        report["능력 줄이 15개 넘음 (뒤는 버림)"].append(f"{no} {lang} {len(abilities)}")
    if len(strs) > MAX_STR:
        report["str이 16개 넘음 (뒤는 버림)"].append(f"{no} {lang} {len(strs)}")
    db.execute("DELETE FROM strings WHERE cid=? AND lang=?", (cid, lang))
    rows = [(cid, lang, STR_ABILITY, i, t) for i, t in enumerate(abilities[:MAX_ABILITY])]
    rows += [(cid, lang, STR_STR, i, t) for i, t in enumerate(strs[:MAX_STR])]
    if life_burst:
        rows.append((cid, lang, STR_LB, 0, life_burst))
    db.executemany("INSERT INTO strings VALUES(?,?,?,?,?)", rows)


def stat_key(c):
    d = c["data"]
    return tuple(nfkc(d.get(k, "")) for k in
                 ("カード種類", "色", "レベル", "パワー", "リミット", "コスト", "グロウコスト"))


def main():
    cards = json.loads(SRC.read_text(encoding="utf-8"))
    cards = [c for c in cards if c.get("card_no") and c["card_no"] != "Not Found"]

    # 1) 배포처 꼬리표 떼기: 프로모(PR/SP/SPK/SPDi) 인쇄본의 '名前（○○付録）' -> '名前'
    #    (확인 결과 전각 괄호 꼬리표는 프로모 번호에만 붙어 있다)
    def base_name(card):
        name = card["name"]
        m = re.match(r"^(.*?)（[^（）]*）$", name)
        if m and re.match(r"^(PR|SP)", card["card_no"]):
            return m.group(1)
        if m:
            report["프로모가 아닌데 괄호 꼬리표 (확인 필요)"].append(f"{card['card_no']} {name}")
        return name

    # 2) 묶기: 이름 + 카드 종류 + 색 + 레벨 (같은 이름의 다른 카드, 예: 흑/녹 'カーニバル' 레벨0 을 분리)
    def lvl(c):
        v = nfkc(c["data"].get("レベル", "")).strip()
        return "0" if v in ("", "-") and "ルリグ" in c["data"].get("カード種類", "") else v

    def canon(key):
        return nfkc("|".join(key))

    def group_key(c):
        d = c["data"]
        return (base_name(c), nfkc(d.get("カード種類", "")), nfkc(d.get("色", "")), lvl(c))

    # 이름의 반각/전각·공백만 다른 인쇄본은 같은 카드다(アロス・ピルルク　TRI / ＴＲＩ. 결정 2026-11-24). 처음 나온 표기를 키로 쓴다
    groups = defaultdict(list)
    first_key = {}
    for c in cards:
        key = group_key(c)
        groups[first_key.setdefault(canon(key), key)].append(c)

    # 같은 이름인데 텍스트·수치가 다르면 보고 (최빈값을 대표로)
    def era(c):
        """대표 텍스트 선택용 시대 순위 (높을수록 최신 표기)"""
        no = c["card_no"]
        if re.match(r"^(WX2[4-9]|WXEX2)", no):
            return 4
        if "Di" in no.split("-")[0] or no.startswith("PR-Di"):
            return 3
        if re.match(r"^(WXK|WDK|SPK|PR-K|WDA)", no):
            return 2
        return 1

    rep = {}
    for key, cs in groups.items():
        name = key[0]
        newest = max(era(c) for c in cs)
        tk = Counter(text_key(c) for c in cs if era(c) == newest)
        sk = Counter(stat_key(c) for c in cs)
        best_t = tk.most_common(1)[0][0]
        best_s = sk.most_common(1)[0][0]
        if len(tk) > 1:
            report["같은 이름, 텍스트 다름 (최빈 텍스트로 통일)"].append(
                f"{name}: " + ", ".join(c["card_no"] for c in cs if text_key(c) != best_t))
        if len(sk) > 1:
            report["같은 이름, 수치 다름 (확인 필요)"].append(
                f"{name}: " + ", ".join(f"{c['card_no']}{stat_key(c)}" for c in cs if stat_key(c) != best_s))
        cand = [c for c in cs if text_key(c) == best_t]
        rep[key] = next((c for c in cand if stat_key(c) == best_s), cand[0])

    # 3) cid 부여 (고정 매핑 유지)
    cid_map = json.loads(CID_MAP.read_text(encoding="utf-8")) if CID_MAP.exists() else {}
    next_cid = max(cid_map.values(), default=0) + 1
    def map_key(key):
        return "|".join(key)

    # 표기만 다른 키는 cid_map.json에서 같은 cid를 가리킨다(빠진 번호는 다시 쓰지 않는다)
    canon_cid = {nfkc(k): v for k, v in cid_map.items()}
    for key in groups:  # cards.json 순서 = 카드 번호 순
        if map_key(key) not in cid_map:
            if canon(key) not in canon_cid:
                canon_cid[canon(key)] = next_cid
                next_cid += 1
            cid_map[map_key(key)] = canon_cid[canon(key)]
    assert next_cid <= OFFICIAL_CID_MAX
    CID_MAP.write_text(json.dumps(cid_map, ensure_ascii=False, indent=0), encoding="utf-8")

    # 판본 순서: idx 1 = 기본 일러. 일반 세트 인쇄본을 PR/SP 등 프로모보다 앞에 둔다
    def print_order(cs):
        return sorted(cs, key=lambda x: (x["card_no"].startswith(("PR", "SP")), x["card_no"]))

    # 카드 번호 -> [cid, idx]. DB에는 카드 번호를 넣지 않는다. 케이스·도구용(배포하지 않는다)
    card_nos = {p["card_no"]: [cid_map[map_key(key)], idx]
                for key, cs in groups.items() for idx, p in enumerate(print_order(cs), 1)}
    CARD_NOS.write_text(json.dumps(card_nos, ensure_ascii=False, indent=0), encoding="utf-8")

    # --decks: 덱 파일에 든 cid의 카드만 남긴다 (cid는 위에서 전체 기준으로 정했다)
    if ONLY_DECKS:
        deck_cids = set()
        for f in sorted((ROOT / "decks").glob("*.json")):
            d = json.loads(f.read_text(encoding="utf-8"))
            for part in ("lrig", "main"):
                deck_cids |= {e[0] for e in d.get(part, [])}
        # 스크립트가 있는 카드도 넣는다(부스터 카드를 덱 없이 케이스로 확인)
        deck_cids |= {int(f.stem[1:]) for f in (ROOT / "script").glob("c*.lua") if f.stem[1:].isdigit()}
        groups = {k: cs for k, cs in groups.items() if cid_map[map_key(k)] in deck_cids}
        found = {cid_map[map_key(k)] for k in groups}
        for cid in sorted(deck_cids - found):
            report["덱 cid 없음 (--decks)"].append(str(cid))

    # 4) DB 작성. 마운트된 폴더에서 SQLite가 I/O 오류를 낼 수 있어 임시 폴더에 만든 뒤 복사한다
    tmp_dir = Path(tempfile.mkdtemp())
    tmp_db = tmp_dir / "wixoss.db"
    db = sqlite3.connect(tmp_db)
    db.executescript("""
    CREATE TABLE cards(
      cid INTEGER PRIMARY KEY,
      type INTEGER,       -- 종류 비트(TYPE_*): ルリグ1 シグニ2 アーツ4 スペル8 アシストルリグ16 トークン32 ピース64 キー128 レゾナ256 クラフト512 コイン1024 リレー2048
      class TEXT,         -- JSON [[系統, 種族], ...]: 시그니 클래스(classes 표의 ID, 콜론 없는 클래스는 種族 0)
      lrig_type TEXT,     -- JSON [ID, ...]: 루리그 타입
      color INTEGER,      -- 비트: 白1 赤2 青4 緑8 黒16, 0=무색, NULL=없음
      level INTEGER, lim INTEGER,
      limit_cost INTEGER, -- 사용 리미트: 시그니를 낼 때 레벨 대신 리미트에 더하는 값. NULL = 레벨
      power INTEGER,      -- -1 = ∞
      cost_ena TEXT,      -- '{R}{C}{C}'. 루리그·어시스트 루리그는 그로우 코스트, 나머지는 사용 코스트
      cost_other TEXT,    -- JSON: {"coin":2}, {"alt":"キー"}
      limit_cond TEXT,    -- JSON [루리그 타입 ID, ...]
      team TEXT,          -- JSON 목록
      coin INTEGER,       -- 코인 아이콘: 오픈 시 얻는 코인
      guard INTEGER,      -- 가드 아이콘
      life_burst INTEGER,
      timing INTEGER,     -- 사용 타이밍 비트: メインフェイズ1 アタックフェイズ2 スペルカットイン4
      formats INTEGER,    -- 포맷 비트: キー1 ディーヴァ2. 인쇄본 아이콘의 합
      source TEXT,        -- 'official' | 'orica'
      alias INTEGER       -- 동명 취급: 이름이 같은 다른 카드의 대표 cid. 0 = 없음(자기가 대표)
    );
    CREATE TABLE prints(  -- 판본. 카드 하나에 여러 장. 카드 번호·레어도·일러스트레이터는 두지 않는다
      cid INTEGER, idx INTEGER,   -- idx: 1부터. 1 = 기본 일러스트
      image TEXT, flavor TEXT,
      PRIMARY KEY(cid, idx)
    );
    CREATE TABLE card_meta( -- 오리카 제작 정보. 공식 카드는 비어 있음
      cid INTEGER PRIMARY KEY, maker TEXT, tags TEXT, pack TEXT,
      created TEXT, modified TEXT
    );
    CREATE TABLE texts(   -- 본문·LB 텍스트는 strings(능력 줄·LB)를 이어 붙여 보여 준다
      cid INTEGER, lang TEXT, name TEXT, reading TEXT,
      PRIMARY KEY(cid, lang)
    );
    CREATE TABLE strings(  -- 효과 설명 문자열. idx는 고정(스크립트가 aux.Ability/Stringid 번호로 가리킨다)
      cid INTEGER, lang TEXT, kind INTEGER, idx INTEGER, text TEXT,
      PRIMARY KEY(cid, lang, kind, idx)
    );
    CREATE TABLE classes(  -- 이름 <-> ID. kind 0 系統(콜론 없는 클래스 포함), 1 種族, 2 루리그 타입. 공식 1~999, 오리카 1000~
      kind INTEGER, id INTEGER, const TEXT, ja TEXT, ko TEXT,
      PRIMARY KEY(kind, id)
    );
    """)

    classes = ClassTable(CLASSES)
    db.executemany("INSERT INTO classes VALUES(?,?,?,?,NULL)", classes.rows)
    same_name = defaultdict(list)
    extra_strings = json.loads(EXTRA_STRINGS.read_text(encoding="utf-8")) if EXTRA_STRINGS.exists() else {}
    for key, cs in groups.items():
        name = key[0]
        same_name[name].append(cid_map[map_key(key)])
        c = rep[key]
        d = c["data"]
        no = c["card_no"]
        cid = cid_map[map_key(key)]
        # 코스트와 그로우 코스트를 둘 다 가진 카드는 없다. 칸이 뒤바뀐 데이터(PR-331 スペル, PR-K046 キー)도 이걸로 맞는다
        cost_field = "コスト" if any(nil(p["data"].get("コスト")) for p in cs) else "グロウコスト"
        # 코스트가 빠진 인쇄본(WD22-005-U)은 다른 인쇄본의 값으로
        cost_raw = d.get(cost_field)
        if not nil(cost_raw):
            cost_raw = next((p["data"].get(cost_field) for p in cs if nil(p["data"].get(cost_field))), cost_raw)
        cost_ena, cost_other = parse_cost(cost_raw, no, cost_field)
        kind = split_multi(d.get("カード種類"))
        is_signi = any(k in ("シグニ", "レゾナ") for k in kind)
        # 클래스·루리그 타입은 인쇄본 합집합(프로모 인쇄본에 「-」로 빠진 것이 있다: PR-382, SP31-003)
        signi_cls, lrig_types = [], []
        for p in cs:
            if is_signi:
                signi_cls += [x for x in classes.signi(p) if x not in signi_cls]
            elif any(k in ("ルリグ", "アシストルリグ") for k in kind):
                lrig_types += [x for x in classes.lrig(classes.raw(p), p["card_no"]) if x not in lrig_types]
            elif nil(p["data"].get("カードタイプ")):
                report["시그니·루리그가 아닌데 カードタイプ (무시)"].append(f"{p['card_no']} {p['data']['カードタイプ']}")
        lb_lines = [s for s in c["skills"] if s.startswith("ライフバースト")]
        body = [s for s in c["skills"] if not s.startswith("ライフバースト")]
        guard_v = nil(d.get("ガード"))
        limit = to_int(d.get("リミット"), "リミット", no)
        if is_signi and limit is not None:
            report["사용 리미트(시그니의 リミット 칸)"].append(f"{no} {name}: {limit}")
        formats = 0
        for p in cs:
            fmt = p["data"].get("フォーマット", "")
            formats |= (FORMAT_KEY if "キー" in fmt else 0) | (FORMAT_DIVA if "ディーヴァ" in fmt else 0)
        db.execute("INSERT INTO cards VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", (
            cid,
            type_bits(kind, no),
            json.dumps(signi_cls),
            json.dumps(lrig_types),
            color_mask(d.get("色")),
            to_int(d.get("レベル"), "レベル", no),
            None if is_signi else limit,
            limit if is_signi else None,
            to_int(d.get("パワー"), "パワー", no),
            cost_ena, json.dumps(cost_other) if cost_other else None,
            json.dumps(classes.lrig(d.get("限定条件"), no, "限定")),
            # 팀은 인쇄본 합집합(재록본에 팀 표기가 빠진 경우가 있다. system_update 「チーム名の追加」: 팀은 카드 단위)
            json.dumps(list(dict.fromkeys(t for p in cs for t in split_multi(p["data"].get("チーム")))),
                       ensure_ascii=False),
            to_int(d.get("コイン"), "コイン", no),
            1 if guard_v in ("あり", "ガード") else 0,
            1 if lb_lines else 0,
            timing_bits(split_multi(d.get("使用タイミング")), no),
            formats,
            "official",
            0,
        ))
        lb_text = "\n".join(s.split("：", 1)[-1] for s in lb_lines) or None
        db.execute("INSERT INTO texts VALUES(?,?,?,?)", (cid, "ja", name, c.get("reading")))
        insert_strings(db, cid, "ja", "\n".join(body), lb_text, no, extra_strings.get(str(cid), {}).get("ja"))
        for idx, p in enumerate(print_order(cs), 1):
            db.execute("INSERT INTO prints VALUES(?,?,?,?)", (
                cid, idx, (p.get("images") or [None])[0], "\n".join(p.get("flavor") or []) or None))
    # 동명 취급: 이름이 같은데 cid가 갈린 카드는 가장 작은 cid를 대표로 alias를 단다
    n_alias = 0
    for name, cids in same_name.items():
        if len(cids) > 1:
            head = min(cids)
            for c2 in cids:
                if c2 != head:
                    db.execute("UPDATE cards SET alias=? WHERE cid=?", (head, c2))
                    n_alias += 1
            report["동명 취급(alias)"].append(f"{name}: {sorted(cids)}")
    # 5) 한국어 텍스트 병합 (texts_ko.json: cid -> 번역)
    ko_path = TOOLS / "texts_ko.json"
    if ko_path.exists():
        ko = json.loads(ko_path.read_text(encoding="utf-8"))
        n_ko = 0
        for key, t in ko.items():
            if key.startswith("_"):
                continue
            cid = int(key)
            if not db.execute("SELECT 1 FROM cards WHERE cid=?", (cid,)).fetchone():
                if not ONLY_DECKS:
                    report["번역 대상 cid 없음"].append(key)
                continue
            db.execute("INSERT OR REPLACE INTO texts VALUES(?,?,?,?)", (cid, "ko", t.get("name"), None))
            insert_strings(db, cid, "ko", t.get("ability", ""), t.get("life_burst"), key,
                           extra_strings.get(key, {}).get("ko"))
            n_ko += 1
        report["한국어 텍스트 병합"].append(f"{n_ko}종")
    if classes.unknown:
        raise SystemExit("tools/classes.json에 없는 클래스·루리그 타입:\n  " + "\n  ".join(sorted(set(classes.unknown))))
    db.commit()

    n_cards = db.execute("SELECT COUNT(*) FROM cards").fetchone()[0]
    n_prints = db.execute("SELECT COUNT(*) FROM prints").fetchone()[0]
    db.close()
    shutil.copyfile(tmp_db, DST)
    shutil.rmtree(tmp_dir, ignore_errors=True)

    lines = [f"카드 {n_cards}종 / 인쇄본 {n_prints}장 -> {DST.name}", ""]
    for k, v in report.items():
        lines.append(f"[{k}] {len(v)}건")
        lines += ["  " + x for x in v[:300]]
        if len(v) > 300:
            lines.append(f"  ... 외 {len(v) - 300}건")
        lines.append("")
    REPORT.write_text("\n".join(lines), encoding="utf-8")
    print("\n".join(lines[:1] + [l for l in lines if l.startswith("[")]))


if __name__ == "__main__":
    main()
