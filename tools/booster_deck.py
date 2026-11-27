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
}[SET]
FILL = ['WX01-100', 'WX01-051', 'WX01-101', 'WX01-102']


def entry(no, n):
    c, i = nos[no]
    return [c, n] + ([i] if i > 1 else [])


def lb(no):
    return any('ライフバースト：' in s for s in by[no]['skills'])


cards = [c for c in A if re.fullmatch(SET + r'-\d{3}', c['card_no'])]
# 모자라면 앞 부스터(같은 색·루리그 타입) 카드로 채운다. 스크립트가 있는 카드만
import os
PREV = [c for c in A if re.fullmatch(r'WX0[1-9]-\d{3}', c['card_no']) and c['card_no'][:4] < SET[:4]
        and os.path.exists('script/c%d.lua' % nos[c['card_no']][0])]
for (lt, cols, zero, name), rev in [(x, r) for r in (False, True) for x in CONF]:
    types = lt.split('/')
    ok_lim = lambda d: d.get('限定条件', '-').replace('限定', '') in ['-', ''] + types + [lt]
    order = cards[::-1] if rev else cards
    lrig = [c['card_no'] for c in cards + PREV if c['data']['カード種類'] == 'ルリグ' and c['data'].get('カードタイプ') == lt]
    seen = {zero}  # 레벨 0은 따로 넣는다
    lrig = [no for no in lrig if not (nos[no][0] in seen or seen.add(nos[no][0]))]
    arts = [c['card_no'] for c in order if c['data']['カード種類'] == 'アーツ' and (c['data']['色'] in cols or c['data']['色'] == '無') and ok_lim(c['data'])
            and not any('使用禁止' in f['q'] + f['a'] for f in c.get('faq', []))]
    L = [entry(no, 1) for no in lrig[:9]]
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
    f = 'decks/%s_%s%s.json' % (SET, name, '2' if rev else '')
    open(f, 'w', encoding='utf8', newline='\n').write(json.dumps({
        'name': '%s %s (시험 덱%s)' % (SET, lt, ' 2' if rev else ''), 'format': 'allstar', 'lrig': L, 'main': main,
        'start_lrig': {'center': zero, 'assist': []}}, ensure_ascii=False).replace('], [', '],\n  [') + '\n')
    print(f, len(L), sum(m[1] for m in main), 'LB 종류', nlb)
