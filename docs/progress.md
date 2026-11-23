|
 
W
D
0
7
 
イ
オ
ナ
 
|
 
1
8
종
(
스
크
립
트
 
1
5
개
,
 
ゼ
ロ
/
メ
イ
デ
ン
은
 
능
력
 
없
음
,
 
サ
ー
バ
ン
ト
 
Ｑ
２
·
Ｏ
２
는
 
기
존
 
판
본
 
2
)
.
 
덱
 
`
W
D
0
7
_
i
o
n
a
`
(
올
스
타
)
.
 
새
 
메
커
니
즘
:
 
강
제
 
어
택
 
`
E
F
F
E
C
T
_
M
U
S
T
_
A
T
T
A
C
K
`
(
다
운
된
 
시
그
니
는
 
제
외
,
 
W
D
0
7
-
0
0
4
 
F
A
Q
 
1
)
| WD06 エルドラ | 18종(스크립트 16개, エルドラ＝マーク０는 능력 없음, サーバント Ｏ는 기존 판본 5). 덱 `WD06_eldora`(올스타). 새 메커니즘: 라이프 클로스 조작(`GetLifetopGroup`·`SendToLife`·`aux.ToLifeTopInOrder`), `EVENT_LIFE_ADDED`(라이프 안 순서 바꾸기는 아님), `EVENT_LIFEBURST`, 효과 크러시 `Duel.Crush`(シィラ의 에나 대체는 `refill` 플래그), `EFFECT_CANNOT_CRUSH`, `EFFECT_SET_BASE_POWER`, 플레이어에 등록하는 「このターン終了時」 트리거. サプライズ・ウィズ・ミー는 아카이브 텍스트가 「デッキの一番上」이지만 FAQ 2와 영문 텍스트대로 라이프 클로스 위로(아카이브 일본어 텍스트 오류, 사용자 확인). 幻水 シィラ는 사용 금지 카드지만 구현. 케이스 12개. 랜덤 대전 미러 500판·다른 덱 4종 각 300판 실패 0 | 완료 |
| WD07 イオナ | 18종(스크립트 15개, ゼロ/メイデン은 능력 없음, サーバント Ｑ２·Ｏ２는 기존 판본 2). 덱 `WD07_iona`(올스타). 새 메커니즘: 강제 어택 `EFFECT_MUST_ATTACK`(다운된 시그니는 제외, WD07-004 FAQ 1), 정면 배치 강제 `EFFECT_MUST_FRONT`(`Duel::front_ok`, 메인 페이즈·효과 모두), `Card:GetFrontCard()`. コードアンチ アイアン·モア·クレイ는 WD06 기본 파워 3장과 같은 모양이라 6장을 `aux.BasePowerWhileClass`로 뽑음(사용자 결정). 케이스 16개. 랜덤 대전 미러 500판·다른 덱 4종 각 300판 실패 0 | 완료 |
| WD08 ウムル | 18종(스크립트 13개, 능력 없는 카드 3장, サーバント Ｄ는 기존 판본 5). 덱 `WD08_umr`(올스타). 새 메커니즘: `EFFECT_FREE_IGNITION`(「【起】能力を…コストを支払わずに使用できる」: SINGLE을 카드에, 한 번 쓰면 사라진다), 트래시에서 쓰는 【起】(`SetRange(LOCATION_TRASH)`). 러너 `t:action`에 n번째 인자. 케이스 11개. 랜덤 대전 미러 500판·다른 덱 3종 각 300판 실패 0 | 완료 |
 
정
면
 
배
치
 
강
제
 
`
E
F
F
E
C
T
_
M
U
S
T
_
F
R
O
N
T
`
(
`
D
u
e
l
:
:
f
r
o
n
t
_
o
k
`
,
 
메
인
 
페
이
즈
·
효
과
 
모
두
)
,
 
`
C
a
r
d
:
G
e
t
F
r
o
n
t
C
a
r
d
(
)
`
.
 
コ
ー
ド
ア
ン
チ
 
ア
イ
ア
ン
·
モ
ア
·
ク
レ
イ
는
 
W
D
0
6
 
기
본
 
파
워
 
3
장
과
 
같
은
 
모
양
이
라
 
6
장
을
 
`
a
u
x
.
B
a
s
e
P
o
w
e
r
W
h
i
l
e
C
l
a
s
s
`
로
 
뽑
음
(
사
용
자
 
결
정
)
.
 
케
이
스
 
1
6
개
.
 
랜
덤
 
대
전
 
미
러
 
5
0
0
판
·
다
른
 
덱
 
4
종
 
각
 
3
0
0
판
 
실
패
 
0
 
|
 
완
료
 
|
 
エ
ル
ド
ラ
 
|
 
1
8
종
(
스
크
립
트
 
1
6
개
,
 
エ
ル
ド
ラ
＝
マ
ー
ク
０
는
 
능
력
 
없
음
,
 
サ
ー
バ
ン
ト
 
Ｏ
는
 
기
존
 
판
본
 
5
)
.
 
덱
 
`
W
D
0
6
_
e
l
d
o
r
a
`
(
올
스
타
)
.
 
새
 
메
커
니
즘
:
 
라
이
프
 
클
로
스
 
조
작
(
`
G
e
t
L
i
f
e
t
o
p
G
r
o
u
p
`
·
`
S
e
n
d
T
o
L
i
f
e
`
·
`
a
u
x
.
T
o
L
i
f
e
T
o
p
I
n
O
r
d
e
r
`
)
,
 
`
E
V
E
N
T
_
L
I
F
E
_
A
D
D
E
D
`
(
라
이
프
 
안
 
순
서
 
바
꾸
기
는
 
아
님
)
,
 
`
E
V
E
N
T
_
L
I
F
E
B
U
R
S
T
`
,
 
효
과
 
크
러
시
 
`
D
u
e
l
.
C
r
u
s
h
`
(
シ
ィ
ラ
의
 
에
나
 
대
체
는
 
`
r
e
f
i
l
l
`
 
플
래
그
)
,
 
`
E
F
F
E
C
T
_
C
A
N
N
O
T
_
C
R
U
S
H
`
,
 
`
E
F
F
E
C
T
_
S
E
T
_
B
A
S
E
_
P
O
W
E
R
`
,
 
플
레
이
어
에
 
등
록
하
는
 
「
こ
の
タ
ー
ン
終
了
時
」
 
트
리
거
.
 
サ
プ
ラ
イ
ズ
・
ウ
ィ
ズ
・
ミ
ー
는
 
아
카
이
브
 
텍
스
트
가
 
「
デ
ッ
キ
の
一
番
上
」
이
지
만
 
F
A
Q
 
2
와
 
영
문
 
텍
스
트
대
로
 
라
이
프
 
클
로
스
 
위
로
(
아
카
이
브
 
일
본
어
 
텍
스
트
 
오
류
,
 
사
용
자
 
확
인
)
.
 
幻
水
 
シ
ィ
ラ
는
 
사
용
 
금
지
 
카
드
지
만
 
구
현
.
 
케
이
스
 
1
2
개
.
 
랜
덤
 
대
전
 
미
러
 
5
0
0
판
·
다
른
 
덱
 
4
종
 
각
 
3
0
0
판
 
실
패
 
0
 
|
 
완
료
 
|
