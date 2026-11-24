# 카드 스크립트 API

카드 스크립트는 `script/c<cid>.lua`(공식, 최상단)나 `expansions/script/c<cid>.lua`(오리카)에 둔다. 유프로식 구조를 따른다.

```lua
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
function s.op(e,tp) Duel.Draw(tp,1) end
```

- 지속 효과에는 문구 종류를 주석으로 남긴다. `-- [まで]` 대상 고정, `-- [の間]` 동적 대상(【常】·「この間」·「このターン」).
- 짜기 전에 DB의 `texts`(ja)와 그 카드의 FAQ(`cards.json`)를 읽는다.
- 플레이어는 0, 1. `tp`는 그 효과를 쓰는 플레이어.

## 효과 종류(SetType)

| 상수 | 뜻 |
| --- | --- |
| `EFFECT_TYPE_SINGLE` | 그 카드 자신에게 거는 효과(자기 파워 수정, 키워드 등) |
| `EFFECT_TYPE_FIELD` | 범위 안의 카드에 거는 효과(`SetTargetRange`, `SetTarget(function(e,c))`) |
| `EFFECT_TYPE_ACTIVATE` | 아츠·스펠·피스의 사용 효과 |
| `EFFECT_TYPE_IGNITION` | 【起】. `SetTiming(TIMING_*)`, 없으면 메인 페이즈 |
| `EFFECT_TYPE_TRIGGER_F` / `_O` | 【自】·【出】 강제 / 임의. `SINGLE`(자기 이벤트) 또는 `FIELD`(남의 이벤트, `SetRange`)와 더한다 |
| `EFFECT_TYPE_LIFEBURST` | 라이프 버스트 |

## Effect

| 함수 | 설명 |
| --- | --- |
| `Effect.CreateEffect(c)` | 새 효과 |
| `e:SetType(t)` `e:SetCode(code)` `e:SetProperty(p)` | |
| `e:SetRange(loc)` | 핸들러가 있어야 하는 위치(`LOCATION_*`) |
| `e:SetTargetRange(self, opp)` | FIELD 효과 범위 |
| `e:SetValue(v)` | 정수, 함수 `(e,c)`. `EFFECT_ADD_CLASS`는 `aux.Class(sys, race)` |
| `e:SetCondition(f)` | 지속: `(e)`, 트리거·【起】: `(e,tp,eg,ep,ev,re,r,rp)` → bool |
| `e:SetDeclare(f)` | `(e,tp,eg,ep,ev,re,r,rp)`. 사용 선언 때(ベット 뒤, 코스트 전, 취소 가능) 모드를 고른다. 고른 모드는 `e:SetLabel`로. 트리거는 대상 바로 앞에 돈다 |
| `e:SetMinCost(f)` | 「使用コストは…減る」 아츠·스펠: `(e,tp)` → 가장 많이 줄였을 때의 에나 코스트(쓸 수 있는지 볼 때). 실제 코스트는 `SetDeclare`에서 `Duel.SetUseCost("{R}{C}")` |
| `e:SetTarget(f)` | `(e,tp,eg,ep,ev,re,r,rp,chk)`. `chk==0`이면 쓸 수 있는지만 돌려준다. 그 외에는 대상을 고른다(코스트를 낸 뒤, 취소 불가. 코스트로 트래시에 간 카드도 후보) |
| `e:SetOperation(f)` | 처리 `(e,tp,eg,ep,ev,re,r,rp)` |
| `e:SetEnaCost("{U}{C}")` | 【起】·【出】의 에나 코스트 |
| `e:SetCost(f)` | 에나 외 코스트. `chk==0`이면 낼 수 있는지, 아니면 낸다(버리기 등). 에나 코스트 뒤, 대상보다 먼저 |
| `e:SetCoinCost(n)` | 코인 코스트(プライマル 등) |
| `e:SetExceedCost(n)` | エクシードＮ: 자기 루리그(센터·어시스트) 아래 카드 N장을 루리그 트래시에 |
| `e:SetEncore(n)` | 아츠의 アンコール(코인 n). 내면 사용 뒤 루리그 덱으로 |
| `e:SetEncoreCost("{B}")` | 에나로 내는 アンコール. 카드 코스트와 같이 낸다 |
| `e:SetBet(n)` | 아츠의 ベット(코인 n). 사용할 때 에나 코스트보다 먼저 묻는다. 처리에서 `Duel.IsBet()`로 확인(용어집: ベット) |
| `e:SetBetCost("{G}")` | 「ベットする場合、使用コストは…になる」: ベット하면 사용 코스트가 이것으로. 원래 코스트를 못 내고 이것만 낼 수 있으면 묻지 않고 ベット |
| `e:SetLabelObject(e2)` | `EFFECT_GRANT`가 부여할 능력의 원형(등록하지 않은 효과) |
| `e:SetCountLimit(n, game)` | 《ターン1回》(n=1). `game`이면 《ゲーム1回》. 턴 제한은 장을 떠났다 오면 새 객체라 다시 센다 |
| `e:SetReset(RESET_PHASE+PHASE_END, n)` | 그 페이즈 끝에 사라진다(「ターン終了時まで」) |
| `e:SetLabel(n)` `e:GetLabel()` | 선언 단계에서 고른 모드 등을 대상·처리 단계로 넘길 때 |
| `e:SetDescription(desc)` `e:GetDescription()` | 효과 설명 번호. 트리거·【起】·아츠·스펠마다 `aux.Ability(id,n)`(카드 텍스트의 n번째 능력, 0부터)을 붙인다. 트리거 순서·「발동할까?」·【起】 메뉴·로그에 그 문장이 나온다. 라이프 버스트는 안 붙여도 된다 |
| `e:GetHandler()` `e:GetOwner()` `e:GetOwnerPlayer()` `e:GetHandlerPlayer()` | |

**코스트가 있는 【出】·【自】**: 코스트를 낼 수 있을 때만 「발동할까」를 묻는다. 낼 수 없으면 묻지 않는다(WXDi-D01-015 FAQ 1). 코스트 → 대상 → 처리 순서다.

## Card

| 함수 | 설명 |
| --- | --- |
| `c:RegisterEffect(e)` | 효과 등록. `initial_effect` 안이면 인쇄 능력 |
| `c:GrantEffect(e)` | 능력 부여(「…を得る」) |
| `c:GetCode()` `c:GetOriginalCode()` | 지금 텍스트의 cid / 인쇄 cid |
| `c:GetPower()` `c:GetLevel()` `c:GetColor()` `c:IsColor(col)` | 현재 값(레이어 계산) |
| `c:IsType(t)` `c:IsSigni()` | |
| `c:IsClass(sys, race)` | 0은 「아무거나」: `c:IsClass(0, RACE_YUGU)`(＜遊具＞), `c:IsClass(SYS_SEIZOU, 0)`(＜精像＞), `c:IsClass(SYS_SEIGEN, 0)`(＜精元＞). 둘 다 0은 오류 |
| `c:GetClasses()` | 클래스 코드(系統 << 16 \| 種族) 목록. 좌우가 다 같아야 같은 코드 |
| `c:IsLrigType(t)` `c:GetLrigTypes()` | 루리그 타입: `c:IsLrigType(LRIG_UMR)` |
| `c:GetLocation()` `c:IsLocation(loc)` `c:GetControler()` `c:GetOwner()` | |
| `c:GetPreviousLocation()` `c:IsPreviousLocation(loc)` | 직전에 있던 곳(「デッキから場に出た場合」「場から手札に戻ったとき」) |
| `c:IsFaceup()` `c:IsDown()` `c:IsUp()` `c:IsFrozen()` | |
| `c:HasKeyword(EFFECT_LANCER)` | 키워드 능력이 있는가 |
| `c:GetZone()` | 지금 있는 존 번호(장 위, 아래 카드면 nil) |
| `c:GetFrontCard()` | 정면 존의 시그니(없으면 nil). 존 레지스트리의 정면 링크 |
| `c:IsLifeBurst()` `c:IsCanAttack()` | 【ライフバースト】를 가졌는가 / 어택할 수 있는가 |
| `c:IsRelateToEffect(e)` | 대상으로 고른 객체가 아직 같은 객체인가 |

## Duel

**조회**

| 함수 | 설명 |
| --- | --- |
| `Duel.GetTurnPlayer()` | |
| `Duel.GetMatchingGroup(f, tp, self_loc, opp_loc, ex, ...)` | 조건에 맞는 카드 묶음 |
| `Duel.IsExistingTarget(f, tp, self_loc, opp_loc, n, ex, ...)` | n장 이상 있는가 |
| `Duel.GetDecktopGroup(p, n)` | 덱 위 n장(맨 위가 첫째) |
| `Duel.GetLifetopGroup(p, n)` | 라이프 클로스 위 n장(맨 위가 첫째) |
| `Duel.IsTeam(p, "アンシエント・サプライズ")` | 루리그 3체가 모두 그 팀인가 |
| `Duel.GetCoin(p)` | 가진 코인 |
| `Duel.GetDeckMovedCount(p)` | 이 턴에 p의 효과로 상대 카드가 메인 덱으로 옮겨진 장수 |
| `Duel.GetSigniZones(p)` `Duel.HasGate(zone)` | 시그니 존 번호 목록 / 【ゲート】가 있는가 |

**선택**(확정 전 단계에서 부르면 취소할 수 있다)

| 함수 | 설명 |
| --- | --- |
| `Duel.SelectTarget(sel, f, tp, self_loc, opp_loc, min, max, ex, ...)` | 대상 지정. `Duel.GetFirstTarget()` `Duel.GetTargets()`로 꺼낸다 |
| `Duel.SelectCards(sel, g, min, max)` | 대상이 아닌 선택. 고르는 사람이 모르는 카드(상대 패 등)는 뒷면으로 보인다(「見ないで選ぶ」) |
| `Duel.SelectDiscard(p, min, max, f, ...)` | p가 자기 패에서 고른다. 버리기는 `Duel.SendToTrash(g, REASON_DISCARD+…)` |
| `Duel.SelectOption(p, aux.Stringid(id,0), aux.Stringid(id,1), ...)` | 모드 선택. 0부터 번호. 선택지에 str 문장(①②는 DB에 자동으로 들어 있다). 문자열을 넘기면(테스트용) 설명 없이 번호만 |
| `Duel.SelectYesNo(p)` | |
| `Duel.GetBanisher()` | `EVENT_BANISHED`의 `SetCondition`에서만: 바니시한 시그니(배틀한 시그니, 또는 장의 시그니 능력). 룰·아츠·스펠·라이프 버스트면 nil |
| `Duel.GetCrusher()` | `EVENT_CRUSHED`의 `SetCondition`에서만: 크러시한 시그니·루리그(어택·【ランサー】·장의 카드 능력). 없으면 nil |
| `Duel.IsBet()` | 처리 중인 아츠를 ベット해서 썼는가 |
| `Duel.CanPayEna(p, "{W}")` `Duel.SelectEnaCost(p, "{W}")` | 처리 중의 「《白》を支払ってもよい」: 낼 수 있는지 보고 `SelectYesNo` 뒤 고른 에나를 `Duel.SendToTrash(g, REASON_COST)` |
| `Duel.SelectZone(p, {zone, ...})` | 존 고르기. 후보가 없으면 nil |
| `Duel.AnnounceNumber(p, lo, hi)` | 숫자 선언 |
| `Duel.SelectOrder(p, g)` | p가 순서를 정한 묶음(「置く順番は対戦相手が選ぶ」 → `SendToDeckBottom(…, false)`) |
| `Duel.RevealCards(g)` | 공개. 양쪽이 본다. 패의 카드면 `EVENT_REVEALED_FROM_HAND` |
| `Duel.ConfirmCards(p, g)` | p가 본다(「見る」) |
| `Duel.SetSelectCheck(f)` | 바로 다음 선택(`SelectTarget`·`SelectCards`·`SelectDiscard`)에 추가 검증 `f(g) → bool`을 건다. 맞지 않는 조합은 거부되고 다시 고른다. 후보가 없어 그 선택을 건너뛰어도 버려진다. 예: `Duel.SetSelectCheck(aux.DistinctClasses)` |

**처리**

| 함수 | 설명 |
| --- | --- |
| `Duel.Draw(p, n)` | 뽑는다 |
| `Duel.EnaCharge(p, n)` | 【エナチャージＮ】. 에나에 놓인 카드 묶음을 돌려준다. 도중에 덱이 없어지면 거기서 끝 |
| `Duel.Banish(c 또는 g)` | 바니시. 시그니 존에 있는 것만, 바니시한 장수를 돌려준다 |
| `Duel.SendToTrash(c 또는 g, reason)` `Duel.SendToHand(…)` `Duel.SendToEna(…)` | 주인의 그 존으로 |
| `Duel.SendToDeckBottom(g, shuffle)` | 덱 맨 아래. `shuffle`이면 섞어서 |
| `Duel.SendToLife(c 또는 g, reason)` | 주인의 라이프 클로스 맨 위에. 밖에서 왔으면 카드마다 `EVENT_LIFE_ADDED`(라이프 안 순서 바꾸기는 아니다) |
| `Duel.Crush(p, n, refill)` | 효과로 라이프 클로스 n장 크러시(버스트는 룰 처리에서). 크러시한 묶음. `refill`이면 그 카드가 에나로 갈 때 대신 트래시 + 덱 위 1장을 라이프에(WD06-009) |
| `Duel.SendToDeckPosition(c, n)` | 덱 위에서 n번째(1 = 맨 위). 덱이 n-1장보다 적으면 맨 아래 |
| `Duel.SendToDeckShuffle(g, p)` | 「デッキに加えてシャッフルする」. 옮긴 카드가 없어도 p의 덱을 섞는다 |
| `Duel.MoveSigni(c, zone)` | 같은 주인의 빈 시그니 존으로(같은 객체) |
| `Duel.PutOnField(c, p, no_play)` | `no_play`면 그 시그니의 【出】은 발동하지 않는다. 시그니를 장에 낸다. 놓을 존은 p가 고른다. 레벨·리미트·한정 조건을 넘으면 못 낸다 |
| `Duel.PutOnFieldAttacking(c, p)` | 「アタックしているシグニとしてダウン状態で場に出す」. 【出】을 처리한 뒤 정면과 배틀하거나 데미지, 「アタックしたとき」는 트리거하지 않는다(WDK-F03-15 FAQ 2) |
| `Duel.SendToLrigTrash(c 또는 g, reason)` | 루리그 트래시로(키를 코스트로 놓기 등) |
| `Duel.Up(c)` | 업한다(동결 상태여도) |
| `Duel.SendToLrigDeck(c 또는 g)` `Duel.PutUnder(host, c 또는 g)` | 루리그 덱으로 / 장의 카드 아래에 놓는다 |
| `Duel.Down(c)` `Duel.Freeze(c)` | 다운 / 동결(동결은 다운하지 않는다) |
| `Duel.AddCoin(p, n)` | 코인을 얻는다(상한 5) |
| `Duel.PlaceGate(zone)` | 【ゲート】를 놓는다. 이미 있으면 false |
| `Duel.HasVirus(zone)` `Duel.PlaceVirus(zone)` `Duel.RemoveVirus(zone)` | 【ウィルス】. 놓기는 이미 있거나 시그니 존이 아니면 false, 치우기는 없으면 false. 치울 때마다 `EVENT_VIRUS_REMOVED` |
| `c:IsInfected()` | 감염 상태(【ウィルス】가 있는 시그니 존에 있다) |
| `Duel.BloodArm(host, card)` | 血晶武装: card(host와 같은 이름의 시그니)를 장의 시그니 host 밑에 놓고 血晶武装状態로. 이미 그 상태가 아니었으면 `EVENT_BLOOD_ARMED`. 못 하면 false |
| `c:IsBloodArmed()` | 血晶武装状態(장을 떠날 때까지. 밑의 카드가 없어져도 유지) |
| `c:IsCross()` | 크로스 상태. 짝이 능력을 잃어도 한쪽이 조건을 채우면 둘 다. 【クロス常】·【クロス出】는 `SetCondition`에서 확인 |
| `c:HasCrossIcon()` | 《クロスアイコン》を持つ(어느 위치든) |
| `c:IsSameName(c2)` | 같은 이름(동명 취급 alias 포함) |
| `Duel.RegisterEffect(e, p)` | 플레이어에 등록(「このターン、あなたの…」 같은 동적 효과) |

**사용 순서**: 선언(ベット·`SetDeclare` 모드) → 에나 코스트 → 확정(코스트를 실제로 냄) → `SetCost` → `SetTarget` → 처리. 코스트로 트래시에 간 카드도 대상이 될 수 있고, 에나를 떠난 카드는 에나 대상이 아니다(WD05-008 FAQ 2, WD04-007 FAQ 1).

**키**: 메인 페이즈에 루리그 덱에서 코스트(에나·코인)를 내고 키 존에 낸다. 1장까지이고, 2장째를 내면 먼저 키는 루리그 트래시에.

**「…は以下の能力を得る」**: FIELD 효과 `EFFECT_GRANT` + `SetTargetRange` + `SetLabelObject(원형)`. 대상마다 원형을 복제해 부여하고, 부여가 걸려 있는 동안만 그 능력을 가진다(동적).

**피스**: 루리그가 3체일 때 루리그 덱에서 쓴다. 【使用条件】은 `SetCondition`으로 쓴다. 쓴 뒤에는 게임에서 제외된다.

## aux (`script/utility.lua`)

코어가 카드 스크립트보다 먼저 읽는다. 같은 판정이 카드 3장 이상에 나오면 여기로 뽑는다(사용자와 정한 뒤).

| 함수 | 설명 |
| --- | --- |
| `aux.BloodArm(tp, c, loc)` | 「それを血晶武装［loc］する」: loc에서 c와 같은 이름의 시그니 1장을 골라 밑에. 패·덱은 안 골라도 되고, 덱이면 그 뒤 섞는다. 놓았으면 true |
| `aux.AddPower(e, tc, v)` | 「ターン終了時まで、それのパワーを＋N/－Nする」: 대상 고정([まで]) 지속 효과를 만들어 건다 |
| `aux.SearchToHand(tp, filter, max)` | 「デッキから…を探して公開し手札に加え、デッキをシャッフルする」: 덱 전부 보기 → 0~max장 공개·패 → 섞기. 패에 넣은 묶음을 돌려준다 |
| `aux.RevealFromHand(tp, filter, n)` | 「手札から…をN枚公開する」: 0장 또는 N장(비공개 영역이라 안 해도 된다). n이 nil이면 「好きな枚数」. 공개한 묶음(패의 【自】가 트리거한다) |
| `aux.ToDeckTopInOrder(tp, g)` | 「好きな順番でデッキの一番上に戻す」: 처음 고른 카드가 맨 위 |
| `aux.ToLifeTopInOrder(tp, g)` | 「好きな順番で(ライフクロスの)一番上に戻す」: 처음 고른 카드가 맨 위. 「加えられた」가 아니다 |
| `aux.BasePower(c, power, con)` | 「(…かぎり)このシグニの基本パワーは N になる」([の間] 【常】). con(e) → bool, 없으면 항상 |
| `aux.BasePowerWhileClass(c, race, power)` | 「あなたの場に他の＜X＞のシグニがあるかぎり、このシグニの基本パワーは N になる」([の間] 【常】). race는 `RACE_*` |
| `aux.Class(sys, race)` | 클래스 코드 하나 |
| `aux.ClassFilter(sys, race)` | 「＜…＞のシグニ」 필터 함수(시그니이고 `IsClass(sys, race)`). `aux.ClassFilter(0, RACE_YUGU)`, `aux.ClassFilter(SYS_SEIZOU, 0)` |
| `aux.ClassCount(g)` | 서로 다른 클래스 수(「クラスが合計Ｎ種類以上」) |
| `aux.DistinctClasses(g)` | 카드마다 서로 다른 클래스를 하나씩 맞출 수 있는가(「それぞれ異なるクラスを持つ」) |
| `aux.NoCommonClass(g)` | 어느 두 장도 같은 클래스가 없는가(「共通するクラスを持たない」) |
| `aux.Ability(id, n)` | 효과 설명 번호: 카드 텍스트의 n번째 능력(0부터, 최대 14) |
| `aux.Stringid(id, n)` | 효과 설명 번호: str n번(0부터, 최대 15). 모드 ①②가 0·1 |
| `aux.EnaChargeOp(n)` | 【エナチャージＮ】 처리 함수. `e:SetOperation(aux.EnaChargeOp(1))`. 조건은 `SetCondition`으로 따로 붙인다 |
| `aux.AddCross(c, cid, side)` | 크로스 조건 「《X》の右／左」(`EFFECT_CROSS` 등록). side는 `CROSS_RIGHT`/`CROSS_LEFT`, 여러 번 부르면 「か」 |
| `aux.AddResonaProc(c, n, filter, loc, timing, min, check)` | 장수가 여러 가지면 min~n장과 조합 검증 `check(g)`(`e:SetCheck`). 【出】의 `ev` = 출현 조건으로 트래시한 시그니의 레벨 합계. 레조나 출현 조건: loc의 filter 시그니 n체를 트래시. timing은 `TIMING_MAIN`/`TIMING_ATTACK`. `EFFECT_RESONA`를 등록 |
| `aux.NonResonaClass(race)` | 「レゾナでない＜X＞のシグニ」 필터 |
| `aux.LifeBurst(id)` | 효과 설명 번호: 라이프 버스트 문장 |

## Group

`Group.CreateGroup(...)` `g:GetCount()` `g:GetFirst()` `g:IsContains(c)` `g:AddCard(c)` `g:Filter(f, ex, ...)` `for c in g:Iter() do … end`

## 상수

- 지속 효과 코드: `EFFECT_SET_POWER` `EFFECT_UPDATE_POWER` `EFFECT_CHANGE_COLOR` `EFFECT_ADD_COLOR` `EFFECT_ADD_CLASS` `EFFECT_CHANGE_LEVEL` `EFFECT_UPDATE_LEVEL` `EFFECT_UPDATE_LIMIT` `EFFECT_LOSE_ABILITY` `EFFECT_COPY` `EFFECT_MULTI_ENA`
- 부여: `EFFECT_GRANT`
- 금지·상한: `EFFECT_CANNOT_ATTACK`, `EFFECT_UPDATE_HAND_LIMIT`(FIELD, `SetTargetRange(1,0)` 자기 / `(0,1)` 상대, 값 ±), `EFFECT_CANNOT_GUARD`(FIELD를 `Duel.RegisterEffect`로 플레이어에, 값 = 가드할 수 없는 시그니 레벨), `EFFECT_CANNOT_BANISH`(「バニッシュされない」: 효과·배틀·파워 0 이하 룰 처리 모두. 바니시가 아닌 이동은 막지 않는다), `EFFECT_PREVENT_DAMAGE`(「次にダメージを受ける場合、代わりにダメージを受けない」: FIELD를 플레이어에, 한 번 쓰면 사라진다), `EFFECT_CANNOT_CRUSH`(「ライフクロスはクラッシュされない」: FIELD를 플레이어에. 어택·효과 모두), `EFFECT_MUST_ATTACK`(「可能ならばアタックしなければならない」: 이걸 가진 시그니가 어택할 수 있는 동안 시그니 어택 스텝을 끝낼 수 없다), `EFFECT_MUST_FRONT`(「対戦相手がシグニを配置する場合、可能ならばこのシグニの正面に」: SINGLE. 메인 페이즈·효과로 놓기 모두), `EFFECT_FREE_IGNITION`(「【起】能力を…コストを支払わずに使用できる」: SINGLE을 카드에. 그 카드의 【起】을 한 번 에나·코스트 없이 쓰고 사라진다. 코인은 낸다), `EFFECT_SET_BASE_POWER`(「基本パワーは…になる」: SET_POWER·UPDATE_POWER보다 먼저), `EFFECT_RESONA`(출현 조건. 값 = 재료 수. `aux.AddResonaProc`로 만든다), `EFFECT_CROSS`(크로스 조건. SINGLE, 값 = 짝의 cid(동명이 갈리면 대표 cid), label = `CROSS_RIGHT`「《X》の右」/ `CROSS_LEFT`「《X》の左」. 여러 개 등록하면 「か」. 3체 크로스의 「かつ」는 아직), `EFFECT_IMMUNE`(「…の効果を受けない」. 값 = `(e, 출처 카드, 출처 플레이어)` → bool. 파워·텍스트 변경, 이동, 상태 변경을 막는다. 이동·바니시 함수의 반환값으로 됐는지 안다), `EFFECT_BANISH_TO_TRASH`(바니시되면 에나 대신 트래시. 플레이어에 등록하면 「このターン」), `EFFECT_SKIP_ENA`(FIELD, `SetTargetRange(0,1)` = 상대), `EFFECT_ATTACK_ONCE`, `EFFECT_GUARD_ICON`(패의 시그니가 《ガードアイコン》を持つ), `EFFECT_GROW_PROC`(루리그에 SINGLE: `SetCost` = 【グロウ】 조건, `SetMinCost`·`SetDeclare`+`Duel.SetUseCost` = 그로우 코스트 감소). `EFFECT_CANNOT_CRUSH`의 값이 `CRUSH_NON_DAMAGE`면 데미지 외의 크러시만 막는다. `EFFECT_NO_GUARD`(FIELD, `(0,1)` = 상대가 가드할 수 없다), `EFFECT_GRANT_LIFEBURST`(FIELD, `(1,0)` = 자기의 모든 영역에서 LB 없는 카드가 `SetLabelObject`의 LB를 얻는다), `EFFECT_NO_ON_PLAY`(시그니의 【出】이 발동하지 않는다. 【出】 = `SINGLE`의 `EVENT_ON_PLAY`. 「このシグニが…場に出たとき」의 【自】는 `e:SetProperty(EFFECT_FLAG_AUTO)`를 붙여 【出】과 구분한다. 남을 보는 FIELD는 원래 【自】라 필요 없다). `EVENT_BANISHED`의 `ev` = 바니시되기 직전의 레벨
- 키워드: `EFFECT_LANCER` `EFFECT_S_LANCER` `EFFECT_DOUBLE_CRUSH` `EFFECT_ASSASSIN` (인쇄는 `SINGLE` + `SetRange(LOCATION_SZONE)`, 부여는 `c:GrantEffect`)
- 이벤트: `EVENT_ON_PLAY` `EVENT_LEAVE_FIELD` `EVENT_BANISHED` `EVENT_TO_TRASH` `EVENT_TO_ENA` `EVENT_TO_HAND` `EVENT_DRAW` `EVENT_ATTACK` `EVENT_CRUSHED` `EVENT_DAMAGE` `EVENT_GROW` `EVENT_REFRESH` `EVENT_TURN_END` `EVENT_MOVED_TO_DECK`(효과 하나에 한 번, eg = 옮겨진 카드, rp = 효과의 플레이어) `EVENT_VIRUS_REMOVED`(【ウィルス】 하나마다, ep = 그 존의 주인, ev = 존 번호) `EVENT_BLOOD_ARMED`(血晶武装状態가 됐을 때만, eg = 그 시그니, ep = 컨트롤러) `EVENT_REVEALED_FROM_HAND`(효과로 패를 공개, 공개 한 번에 한 번. eg = 공개한 카드, ep = 패 주인, rp = 효과의 플레이어. 패의 카드 자신의 【自】는 `SetRange(LOCATION_HAND)`) `EVENT_LIFE_ADDED`(라이프 클로스에 1장 더해질 때마다, ep = 그 라이프의 주인) `EVENT_LIFEBURST`(라이프 버스트를 발동했다, ep = 주인) `EVENT_HEAVEN`(《ヘブン》した. eg = 크로스한 시그니 전부, ep = 컨트롤러. 「このシグニが《ヘブン》したとき」는 SINGLE) `EVENT_PHASE_START+PHASE_*` `EVENT_CUSTOM`
- 이유: `REASON_RULE` `REASON_EFFECT` `REASON_BATTLE` `REASON_COST` `REASON_DISCARD` `REASON_DAMAGE`
- 위치: `LOCATION_MDECK` `LOCATION_LIFE` `LOCATION_LDECK` `LOCATION_HAND` `LOCATION_TRASH` `LOCATION_LTRASH` `LOCATION_ENA` `LOCATION_CHECK` `LOCATION_EXCLUDE` `LOCATION_LRIG` `LOCATION_ASSIST` `LOCATION_KEY` `LOCATION_SIGNI` `LOCATION_CHEER` `LOCATION_SZONE` `LOCATION_FIELD`
- 클래스·루리그 타입: `SYS_*`(系統, 콜론 없는 클래스 포함) `RACE_*`(種族) `LRIG_*`. 카드 DB의 `classes` 표에서 온다(목록: `tools/classes.json`)
- 그 외: `TYPE_*` `COLOR_*` `TIMING_MAIN` `TIMING_ATTACK` `TIMING_CUTIN` `PHASE_*` `RESET_PHASE`
- `math.random`은 코어 PRNG다(결정론).
