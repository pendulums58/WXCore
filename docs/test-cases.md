# 테스트 케이스 작성법

룰·FAQ 케이스는 `runner/cases/*.lua`에 쓴다. 러너는 이 폴더를 바로 읽으므로 케이스를 추가·수정할 때 다시 빌드하지 않는다.
코어 내부를 직접 봐야 하는 것(PRNG 기준값, 존·객체 기본 연산, C API 바이트)만 `runner/cases/*.cpp`에 둔다.

실제 카드를 쓰는 케이스는 카드 DB가 있어야 한다. 처음 한 번 `python tools/build_db.py`로 만든다(아카이브 `cards.json`을 읽는다).

```
build/msvc/runner/Debug/wx_runner.exe          전체
build/msvc/runner/Debug/wx_runner.exe rule2     이름이나 파일 이름에 "rule2"가 든 것만
build/msvc/runner/Debug/wx_runner.exe --fuzz 1000 1     랜덤 AI 대전 1000판(시드 1부터, 가짜 카드 풀)
build/msvc/runner/Debug/wx_runner.exe --fuzz 200 1 --deck WXDi-D01_ancient_surprise --deck2 WDK09_blue_umr
                                                실제 덱(DB·스크립트). --deck2를 빼면 미러전
```

랜덤 대전(`runner/fuzz.cpp`)은 공개 C API만 써서 요청마다 아무 후보나 고르고, 가끔 취소·되돌리기를 섞는다.
크래시, 끝나지 않는 대전, 응답할 수 없는 요청, 코어 로그, 깨진 메시지를 실패로 본다.
실패하면 시드가 찍힌다. `--fuzz 1 <시드> -t`로 그 판의 메시지·응답을 전부 볼 수 있다(`--no-undo`로 되돌리기 끄기).
평소 전체 실행에도 30판이 들어 있다.

## 모양

```lua
case("이름", "근거(카드 번호 + FAQ 번호, 또는 용어집 항목)", function(t)
  t:signi(100, 5000)            -- 카드 데이터 정의
  t:start()                     -- 대전 생성(테스트 모드)
  local c = t:put(100, 0, "signi_left")
  t:begin(0, PHASE_ATTACK)      -- 지금 장 그대로 그 페이즈부터
  t:wait(HINT_ATTACK_SIGNI)     -- 그 요청이 나올 때까지 진행
  t:answer(c)
  t:wait(HINT_MAIN)
  t:expect(t:count(1, "life_cloth") == 1, "실패할 때 보일 설명")
end)
```

- 카드는 정수 번호로 다룬다(`put`이 돌려준 값).
- 플레이어는 0, 1. 존 이름은 아래 표.
- 케이스가 끝났을 때 코어 로그(스크립트 오류 등)가 있으면 실패로 본다. 로그가 나와야 정상인 케이스는 `t:allow_logs()`.

## 존 이름

`main_deck` `life_cloth` `lrig_deck` `hand` `trash` `lrig_trash` `ena` `check` `exclude`
`lrig_center` `lrig_assist_left` `lrig_assist_right` `key` `signi_left` `signi_center` `signi_right` `cheer`

## API

**카드 데이터·스크립트** (`start` 전후 어느 때든, 카드를 처음 쓰기 전에)

| 함수 | 설명 |
| --- | --- |
| `t:signi(cid, power, color, level)` | 시그니. color·level 생략 시 백·1 |
| `t:lrig(cid, level, limit, {types}, color)` | 루리그 |
| `t:card{cid=, type=, color=, level=, limit=, power=, classes={}, limit_cond={}, cost=, grow=, guard=, burst=, timing=}` | 아무 카드. type 생략 시 시그니 |
| `t:script(cid, code)` | `c<cid>.lua` 내용 |

**대전**

| 함수 | 설명 |
| --- | --- |
| `t:start{seed=, always_ask=, test_mode=, first=, db=}` | 대전 생성. 다시 부르면 새 대전. always_ask 기본 켬(메인마다 멈춤). `db=true`면 `t:card`로 정의하지 않은 카드는 실제 DB·`script/`에서 읽는다 |
| `t:no(card_no)` | 카드 번호 → cid(DB). 예: `t:put(t:no("WXDi-D01-012"), 0, "hand")` |
| `t:deck_file(p, name)` | `decks/<name>.json`을 그 플레이어 덱으로. → 성공, `{format, main, lrig, center}` 또는 오류 |
| `t:put(cid, p, zone)` / `t:fill(cid, p, zone, n)` | 카드 생성 |
| `t:deck(p, {main}, {lrig})` + `t:start_game()` | 게임 시작 절차부터 |
| `t:begin(p, phase, first_turn)` | 테스트 모드: 그 턴 그 페이즈부터 |
| `t:wait(hint)` | 그 요청까지 진행. 사이의 요청은 기본 응답(안 고름·아니오·페이즈 종료). 대전이 끝나면 false |
| `t:answer(a, b, ...)` / `t:answer({...})` | 응답. (성공, 거부 이유) |
| `t:cancel()` | 확정 전 선택 취소 |
| `t:request()` | `{player, hint, min, max, cancelable, options}` |
| `t:action(kind, card, zone)` | 행동 번호(없으면 nil). kind: `ACT_END` `ACT_PLAY` `ACT_REMOVE` `ACT_USE` `ACT_ABILITY` `ACT_GROW`(어시스트 그로우, zone = 어시스트 존) `ACT_KEY`(키 내기). 존 이름은 지금 고르는 플레이어 기준 |
| `t:saw(hint)` | `wait`가 기본 응답으로 넘긴 요청 중에 있었는가 |
| `t:undo()` | 마지막 응답(`wait`의 기본 응답 포함)을 되돌린다. 그 뒤에 한 조작도 없어진다. 카드 번호는 그대로 쓸 수 있다 |

**조회**

`t:count(p, zone)` `t:cards(p, zone)` `t:at(c)`(존 이름, 주인) `t:is_in(c, p, zone)`
`t:power(c)` `t:power_raw(c)` `t:keyword(c, EFFECT_LANCER)` `t:level(c)` `t:color(c)` `t:text(c)` `t:cid(c)` `t:oid(c)` `t:flags(c)` `t:face_up(c)`
`t:center(p)` `t:under(c)` `t:can_see(p, c)` `t:turn_player()` `t:ended()` `t:winner()` `t:refreshes(p)`
`t:coins(p)` `t:gate(p, zone)` `t:hand_limit(p)` `t:global(name)` — 카드 스크립트가 남긴 전역 값(표는 공백으로 이은 문자열) `t:logs()`

**조작(테스트 모드)**

| 함수 | 설명 |
| --- | --- |
| `t:move(c, p, zone, bottom)` `t:attach(c, host)` `t:put_under(c, host)` `t:set_flags(c, f)` | 상태 직접 조작 |
| `t:remove_zone(p, zone, by)` | 존 지우기 |
| `t:add_coin(p, n)` `t:place_gate(p, zone)` | 코인 얻기 / 【ゲート】 놓기 |
| `t:single(c, code, value, by, reset)` | 「～まで」 고정 대상 효과 |
| `t:field(code, value, by, self_loc, opp_loc, reset)` | 「～の間」「このターン」 동적 효과 |
| `t:grant(c, code, value, by)` | 능력 부여 |
| `t:suppress(by, reset)` | 이노센스 |
| `t:copy(c, cid, by, reset)` | 조커 |
| `t:reset_phase(phase)` | 그 페이즈 끝 리셋 |

**판정**: `t:expect(조건, 설명)`, `t:allow_logs()`

상수: `PHASE_*` `RESET_PHASE` `EFFECT_*` `LOCATION_*` `TYPE_*` `COLOR_*` `TIMING_*` `CF_DOWN` `CF_FROZEN` `HINT_*`
