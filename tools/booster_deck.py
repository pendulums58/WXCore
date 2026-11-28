# 부스터 카드로 만든 랜덤 대전용 시험 덱(공식 덱이 아니다). python tools/booster_deck.py WX04
# 루리그마다 순서대로·거꾸로 2개. 루리그 타입이 맞는 루리그, 색이 맞는 아츠·시그니·스펠, 모자라면 서번트
import json, re, sys
A = json.load(open(r'D:\Claude Workspace\WixossArchive\cards.json', encoding='utf8'))
nos = json.load(open('tools/card_nos.json', encoding='utf8'))
by = {c['card_no']: c for c in A}
SET = sys.argv[1]
CONF = {
    'WX02': [('タマ', ['白'], 1, 'tama'), ('花代/ユヅキ', ['赤', '緑'], 2, 'yuzuki'), ('エルドラ', ['青'], 42, 'eldora'), ('ウリス', ['黒'], 41, 'urith'), ('緑子', ['緑'], 4, 'midoriko')],
    'WX03': [('タマ', ['白'], 1, 'tama'), ('花代', ['赤'], 2, 'hanayo'), ('ピルルク', ['青'], 3, 'piruluk'), ('緑子', ['緑'], 4, 'midoriko'), ('ウリス', ['黒'], 41, 'urith'), ('ウムル', ['黒'], 34, 'umr')],
    'WX04': [('タマ', ['白'], 1, 'tama'), ('ユヅキ', ['赤'], 25, 'yuzuki'), ('ミルルン', ['青'], 45, 'mirurun'), ('アン', ['緑'], 44, 'an'), ('イオナ', ['黒', '白'], 43, 'iona'), ('花代', ['赤'], 2, 'hanayo'), ('ウリス', ['黒'], 41, 'urith'), ('緑子', ['緑'], 4, 'midoriko'), ('ピルルク', ['青'], 3, 'piruluk')],
    'WX05': [('タマ', ['白'], 1, 'tama'), ('花代', ['赤'], 2, 'hanayo'), ('ピルルク', ['青'], 3, 'piruluk'), ('緑子', ['緑'], 4, 'midoriko'), ('タマ', ['黒'], 1, 'tamayori'), ('ウリス', ['黒'], 41, 'urith'), ('ユヅキ', ['赤'], 25, 'yuzuki'), ('エルドラ', ['青'], 42, 'eldora'), ('ミルルン', ['青'], 45, 'mirurun'), ('アン', ['緑'], 44, 'an')],
    'WX06': [('タウィル', ['白'], 113, 'tawil'), ('ミルルン', ['青'], 45, 'mirurun'), ('アン', ['緑'], 44, 'an'), ('ウムル', ['黒'], 34, 'umr'), ('花代', ['赤'], 2, 'hanayo'), ('緑子', ['緑'], 4, 'midoriko')],
    'WX07': [('サシェ', ['白'], 87, 'sashe'), ('タマ', ['赤'], 1, 'tama'), ('ミルルン', ['青'], 45, 'mirurun'), ('緑子', ['緑'], 4, 'midoriko'), ('ウリス', ['黒'], 41, 'urith')],
    'WX08': [('花代', ['赤'], 2, 'hanayo'), ('ピルルク', ['青'], 3, 'piruluk'), ('アン', ['緑'], 44, 'an'), ('ミュウ', ['黒'], 114, 'myu')],
    'WX09': [('タウィル', ['白'], 113, 'tawil'), ('ウムル', ['黒'], 34, 'umr'), ('リメンバ', ['白', '青'], 33, 'remember')],
    'WX10': [('タマ', ['赤', '白'], 1, 'tama'), ('エルドラ', ['青'], 42, 'eldora'), ('アイヤイ', ['緑'], 133, 'aiyai'), ('サシェ', ['白'], 87, 'sashe'), ('花代', ['赤'], 2, 'hanayo'), ('ミュウ', ['黒'], 114, 'myu')],
    'WX11': [('タマ', ['白'], 1, 'tama'), ('イオナ', ['白'], 43, 'yuki'), ('花代', ['赤'], 2, 'hanayo'), ('ピルルク', ['青'], 3, 'piruluk'), ('緑子', ['緑'], 4, 'midoriko'), ('ウリス', ['黒'], 41, 'urith')],
    'WX12': [('タウィル', ['白'], 113, 'tawil'), ('ユヅキ', ['赤', '緑'], 25, 'yuzuki'), ('ピルルク', ['青', '黒'], 3, 'piruluk'), ('ウムル', ['黒'], 34, 'umr'), ('ミルルン', ['青'], 45, 'mirurun')],
    'WX13': [('ユヅキ', ['赤', '緑'], 25, 'yuzuki'), ('ハナレ', ['黒'], 167, 'hanare'), ('サシェ', ['白'], 87, 'sashe'), ('アイヤイ', ['緑'], 133, 'aiyai'), ('ミュウ', ['黒'], 114, 'myu')],
    'WX14': [('イオナ', ['白', '黒'], 43, 'iona'), ('ピルルク', ['青', '黒'], 3, 'piruluk'), ('花代', ['赤'], 2, 'hanayo'), ('タマ', ['白'], 1, 'tama'), ('緑子', ['緑'], 4, 'midoriko'), ('ハナレ', ['黒'], 167, 'hanare')],
    'WX15': [('リル', ['赤'], 214, 'ril'), ('あや', ['青'], 215, 'aya'), ('メル', ['緑'], 216, 'mel'), ('ナナシ', ['黒'], 218, 'nanashi')],
    'WX16': [('ドーナ', ['白'], 213, 'dona'), ('リル', ['赤'], 214, 'ril'), ('あや', ['青'], 215, 'aya'), ('ママ', ['緑'], 217, 'mama'), ('メル', ['緑'], 216, 'mel'), ('ナナシ', ['黒'], 218, 'nanashi')],
    'WX17': [('カーニバル', ['赤'], 0, 'carnival'), ('ピルルク', ['青'], 3, 'piruluk'), ('ドーナ', ['白'], 213, 'dona'), ('リル', ['赤'], 214, 'ril'), ('あや', ['青'], 215, 'aya'), ('ママ', ['緑'], 217, 'mama'), ('メル', ['緑'], 216, 'mel'), ('ナナシ', ['黒'], 218, 'nanashi')],
    'WX17': [('カーニバル', ['赤'], 240, 'carnival'), ('ピルルク', ['青'], 3, 'piruluk'), ('ドーナ', ['白'], 213, 'dona'), ('リル', ['赤'], 214, 'ril'), ('あや', ['青'], 215, 'aya'), ('ママ', ['緑'], 217, 'mama'), ('メル', ['緑'], 216, 'mel'), ('ナナシ', ['黒'], 218, 'nanashi')],
    'WX18': [('ウリス', ['黒'], 41, 'urith'), ('グズ子', ['黒'], 244, 'guzuko'), ('ミュウ', ['黒'], 114, 'myu'), ('花代', ['赤'], 2, 'hanayo'), ('カーニバル', ['赤'], 240, 'carnival'), ('ドーナ', ['白'], 213, 'dona')],
    'WX19': [('タマ', ['白', '赤'], 1, 'tama'), ('カーニバル', ['赤'], 240, 'carnival'), ('エルドラ', ['青'], 42, 'eldora'), ('イオナ', ['白'], 43, 'iona'), ('ママ', ['緑'], 217, 'mama'), ('グズ子', ['黒'], 244, 'guzuko'), ('ナナシ', ['黒'], 218, 'nanashi'), ('緑子', ['緑'], 4, 'midoriko')],
    'WX20': [('リル', ['赤'], 214, 'ril'), ('メル', ['緑'], 216, 'mel'), ('タマ', ['白'], 1, 'tama'), ('ウリス', ['黒'], 41, 'urith'), ('ナナシ', ['黒'], 218, 'nanashi'), ('あや', ['青'], 215, 'aya'), ('カーニバル', ['赤'], 240, 'carnival'), ('サシェ', ['白', '赤'], 87, 'sashe')],
    'WX21': [('ドーナ', ['白'], 213, 'dona'), ('ユヅキ', ['赤', '緑'], 25, 'yuzuki'), ('あや', ['青'], 215, 'aya'), ('ママ', ['緑'], 217, 'mama'), ('ナナシ', ['黒'], 218, 'nanashi'), ('タウィル', ['赤', '青', '緑'], 113, 'tawil'), ('エルドラ', ['青'], 42, 'eldora'), ('緑子', ['緑'], 4, 'midoriko')],
    'WX22': [('グズ子', ['黒'], 244, 'guzuko'), ('タウィル', ['赤', '青', '緑'], 113, 'tawil'), ('ミルルン', ['青'], 45, 'mirurun'), ('アイヤイ', ['緑'], 133, 'aiyai'), ('アン', ['緑', '白'], 44, 'an'), ('ハナレ', ['黒'], 167, 'hanare'), ('アルフォウ', ['黒'], 168, 'alfou'), ('ドーナ', ['白'], 213, 'dona')],
    # 번외(프로모): 그 세트에만 나온 카드로 시험(스크립트가 있는 것만)
    'PR': [('タマ', ['白'], 1, 'tama'), ('リメンバ', ['白', '青'], 33, 'remember'), ('アルフォウ', ['黒'], 168, 'alfou'), ('ウムル', ['白', '黒'], 34, 'umr'),
           ('花代', ['赤'], 2, 'hanayo'), ('緑子', ['緑'], 4, 'midoriko'), ('ミュウ', ['黒'], 114, 'myu'), ('ハナレ', ['黒'], 167, 'hanare'),
           ('タウィル', ['白', '黒'], 113, 'tawil'), ('ピルルク', ['青'], 3, 'piruluk')],
    'PR-K': [('タマ', ['白'], 1, 'tama'), ('ウムル', ['黒'], 34, 'umr'), ('花代', ['赤', '緑'], 2, 'hanayo'), ('ピルルク', ['青'], 3, 'piruluk'),
             ('ウリス', ['黒'], 41, 'urith'), ('リル', ['赤'], 214, 'ril')],
    # 레벨 0은 SP33의 색 루리그(루리그 타입을 고른다)도 섞는다
    'SP': [('タマ', ['白'], 593, 'tama'), ('花代', ['赤'], 602, 'hanayo'), ('アン', ['緑', '白'], 44, 'an'), ('ユヅキ', ['赤'], 25, 'yuzuki'),
           ('リル', ['赤'], 214, 'ril'), ('メル', ['緑'], 610, 'mel'), ('あや', ['青'], 606, 'aya'), ('ナナシ', ['黒'], 615, 'nanashi'),
           ('ドーナ', ['白'], 213, 'dona'), ('カーニバル', ['赤'], 240, 'carnival'), ('エルドラ', ['青'], 42, 'eldora'), ('タウィル', ['赤'], 113, 'tawil')],
    'SPK': [('レイラ', ['赤'], 345, 'layla'), ('ピルルク', ['青'], 3, 'piruluk'), ('緑子', ['緑'], 4, 'midoriko'), ('タマ', ['白'], 1, 'tama'),
            ('リル', ['赤'], 214, 'ril'), ('カーニバル', ['黒'], 240, 'carnival'), ('リメンバ', ['青'], 33, 'remember'), ('グズ子', ['黒'], 244, 'guzuko'),
            ('イオナ', ['白'], 43, 'iona'), ('エルドラ', ['青'], 42, 'eldora'), ('ユヅキ', ['緑'], 25, 'yuzuki'), ('アン', ['緑'], 44, 'an'),
            ('ミルルン', ['青'], 45, 'mirurun'), ('サシェ', ['白'], 87, 'sashe'), ('アイヤイ', ['緑'], 133, 'aiyai'), ('ハナレ', ['黒'], 167, 'hanare')],
    'WXK06': [('エマ', ['白'], 1710, 'emma'), ('ウムル', ['青'], 34, 'umr'), ('ウリス', ['黒'], 41, 'urith'), ('イオナ', ['黒'], 43, 'iona'), ('ピルルク', ['青', '黒'], 3, 'piruluk')],
    'WXK05': [('タマ', ['白'], 1, 'tama'), ('イオナ', ['白'], 43, 'iona'), ('LoV', ['赤'], 362, 'lov'), ('エルドラ', ['青'], 42, 'eldora'), ('ユヅキ', ['緑'], 25, 'yuzuki'), ('カーニバル', ['黒'], 240, 'carnival')],
    'WXK04': [('イオナ', ['白'], 43, 'iona'), ('LoV', ['赤'], 362, 'lov'), ('エルドラ', ['青'], 42, 'eldora'), ('ユヅキ', ['緑'], 25, 'yuzuki')],
    'WXK03': [('タマ', ['白'], 1, 'tama'), ('リル', ['赤'], 214, 'ril'), ('レイラ', ['赤'], 345, 'layla'), ('ピルルク', ['青'], 3, 'piruluk'), ('リメンバ', ['青'], 33, 'remember'),
              ('緑子', ['緑'], 4, 'midoriko'), ('カーニバル', ['黒'], 240, 'carnival'), ('グズ子', ['黒'], 244, 'guzuko'), ('夢限', ['無', '白', '黒'], 320, 'mugen')],
    'WXK02': [('タマ', ['白'], 1, 'tama'), ('リル', ['赤'], 214, 'ril'), ('リメンバ', ['青'], 33, 'remember'), ('カーニバル', ['黒'], 240, 'carnival')],
    'WXK01': [('レイラ', ['赤'], 345, 'layla'), ('ピルルク', ['青'], 3, 'piruluk'), ('緑子', ['緑'], 4, 'midoriko'), ('グズ子', ['黒'], 244, 'guzuko')],
}[SET]
# 키 세트(번외·WXK)는 키도 루리그 덱에 넣고 루리그는 5장까지
KEYSET = not SET.startswith('WX') or SET.startswith('WXK')
FILL = ['WX01-100', 'WX01-051', 'WX01-101', 'WX01-102']


def entry(no, n):
    c, i = nos[no]
    return [c, n] + ([i] if i > 1 else [])


def lb(no):
    return any('ライフバースト：' in s for s in by[no]['skills'])


cards = [c for c in A if re.fullmatch(SET + (r'\d{2}-\d{3}' if SET == 'SP' else r'\d{2}-\d{2}[AB]?' if SET == 'SPK' else r'\d{3}[AB]?' if SET.endswith('K') else r'-\d{3}'), c['card_no'])]
if SET in ('SP', 'SPK'):  # 재록이 아닌 것(번외에만 나온 카드)만
    import collections as _co
    _all = _co.defaultdict(list)
    for _no, (_cid, _) in nos.items():
        _all[_cid].append(_no)
    cards = [c for c in cards if all(re.match(r'(PR|SP)', n) for n in _all[nos[c['card_no']][0]])]
if not SET.startswith('WX'):
    import os as _os
    cards = [c for c in cards if _os.path.exists('script/c%d.lua' % nos[c['card_no']][0])]
# 모자라면 앞 부스터(같은 색·루리그 타입) 카드로 채운다. 스크립트가 있는 카드만
import os
PREV = [c for c in A if re.fullmatch(r'WX0[1-9]-\d{3}', c['card_no']) and (c['card_no'][:4] < SET[:4] or not SET.startswith('WX'))
        and os.path.exists('script/c%d.lua' % nos[c['card_no']][0])]
for (lt, cols, zero, name), rev in [(x, r) for r in (False, True) for x in CONF]:
    types = lt.split('/')
    ok_lim = lambda d: d.get('限定条件', '-').replace('限定', '') in ['-', ''] + types + [lt]
    order = cards[::-1] if rev else cards
    lrig = [c['card_no'] for c in cards + PREV if c['data']['カード種類'] == 'ルリグ' and lt in c['data'].get('カードタイプ', '').split('/')]  # 「タウィル/ウムル」 같은 겸용도
    seen = {zero}  # 레벨 0은 따로 넣는다
    lrig = [no for no in lrig if not (nos[no][0] in seen or seen.add(nos[no][0]))]
    kinds = ('アーツ', 'キー') if KEYSET else ('アーツ',)
    arts = [c['card_no'] for c in order if c['data']['カード種類'] in kinds and (c['data']['色'] in cols or c['data']['色'] == '無') and ok_lim(c['data'])
            and not any('使用禁止' in f['q'] + f['a'] for f in c.get('faq', []))]
    # 이름이 같은 판본(프로모 재록 등)은 한 장만
    base = lambda no: re.sub(r'（[^）]*）$', '', by[no]['name'])
    names = set()
    arts = [no for no in arts if not (base(no) in names or names.add(base(no)))]
    L = [entry(no, 1) for no in lrig[:5 if KEYSET else 9]]  # 번외는 아츠·키 자리를 남긴다
    L += [[zero, 1]] + [entry(no, 1) for no in arts[:9 - len(L)]]
    main, nlb = [], 0
    for c in order + PREV:
        d = c['data']
        if any(m[0] == nos[c['card_no']][0] for m in main):
            continue
        if d['カード種類'] not in ('シグニ', 'スペル') or d['色'] not in cols or not ok_lim(d):
            continue
        if any('使用禁止' in f['q'] + f['a'] for f in c.get('faq', [])) or (lb(c['card_no']) and nlb >= 4):
            continue
        nlb += lb(c['card_no'])
        main.append(entry(c['card_no'], 4))
        if len(main) == 10:
            break
    for no in FILL:
        if len(main) < 10 and not (lb(no) and nlb >= 5):
            nlb += lb(no)
            main.append(entry(no, 4))
    for c in PREV:  # 그래도 모자라면 앞 부스터의 라이프 버스트 없는 같은 색 시그니
        if len(main) < 10 and c['data']['カード種類'] == 'シグニ' and c['data']['色'] in cols and not lb(c['card_no'])                 and ok_lim(c['data']) and not any(m[0] == nos[c['card_no']][0] for m in main):
            main.append(entry(c['card_no'], 4))
    f = 'decks/%s_%s%s.json' % (SET, name, '2' if rev else '')
    open(f, 'w', encoding='utf8', newline='\n').write(json.dumps({
        'name': '%s %s (시험 덱%s)' % (SET, lt, ' 2' if rev else ''), 'format': 'allstar', 'lrig': L, 'main': main,
        'start_lrig': {'center': zero, 'assist': []}}, ensure_ascii=False).replace('], [', '],\n  [') + '\n')
    print(f, len(L), sum(m[1] for m in main), 'LB 종류', nlb)
