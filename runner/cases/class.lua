-- 시그니 클래스 (系統, 種族)와 루리그 타입. 상수는 카드 DB의 classes 표로 만든 classes.lua

-- 스크립트가 읽힐 때 판정 결과를 전역 R<cid>에 적는다
local PROBE = [[
local s,id=GetID()
function s.initial_effect(c)
  local r={}
  for _,q in ipairs({{SYS_SEIZOU,RACE_AKUMA},{0,RACE_AKUMA},{SYS_SEIZOU,0},{SYS_SEIGEN,0},{0,RACE_YUGU}}) do
    r[#r+1]=tostring(c:IsClass(q[1],q[2]))
  end
  _G["R"..id]=table.concat(r," ")
  _G["N"..id]=#c:GetClasses()
end
]]

case("class: c:IsClass(sys, race) — 좌우 일치, 種族만, 系統만, 콜론 없는 클래스", "용어집: クラス, WX20-007", function(t)
  t:lrig(1, 3, 9, {"タマ"})
  t:card{cid = 200, power = 1000, level = 1, classes = {"精像：悪魔"}}
  t:card{cid = 201, power = 1000, level = 1, classes = {"奏像：悪魔", "精武：遊具"}}
  t:card{cid = 202, power = 1000, level = 1, classes = {"精元"}}
  for cid = 200, 202 do t:script(cid, PROBE) end
  t:start()
  t:put(1, 0, "lrig_center")
  for cid = 200, 202 do t:put(cid, 0, "hand") end
  -- 精像：悪魔 / 悪魔 / 精像 / 精元 / 遊具
  t:expect(t:global("R200") == "true true true false false")
  t:expect(t:global("R201") == "false true false false true")  -- 奏像：悪魔는 ＜精像：悪魔＞·＜精像＞가 아니다
  t:expect(t:global("R202") == "false false false true false")
  t:expect(t:global("N201") == 2)
end)

case("class: 상수는 classes 표에서, 루리그 타입은 IsLrigType", "용어집: ルリグタイプ, WDK09-009", function(t)
  t:lrig(1, 3, 9, {"ウムル"})
  t:script(1, [[
local s,id=GetID()
function s.initial_effect(c)
  UMR=c:IsLrigType(LRIG_UMR)
  TAMA=c:IsLrigType(LRIG_TAMA)
  NTYPES=#c:GetLrigTypes()
end
]])
  t:start()
  t:put(1, 0, "lrig_center")
  t:expect(t:global("SYS_SEIZOU") == 3 and t:global("RACE_YUGU") == 4 and t:global("LRIG_UMR") == 12)
  t:expect(t:global("UMR") == true and t:global("TAMA") == false and t:global("NTYPES") == 1)
end)

-- aux.ClassFilter: utility.lua는 DB를 켠 케이스에서 읽힌다(t:start{db = true}). 카드 정의는 t:card가 우선
local FILTER = [[
local s,id=GetID()
function s.initial_effect(c)
  YUGU=(YUGU or "")..tostring(aux.ClassFilter(0,RACE_YUGU)(c)).." "
  SEIZOU=(SEIZOU or "")..tostring(aux.ClassFilter(SYS_SEIZOU,0)(c)).." "
end
]]

case("class: aux.ClassFilter — ＜遊具＞는 精武·奏武 둘 다, ＜精像＞는 精像 계열만", "용어집: クラス, WX20-007 ダーク・コグネイト", function(t)
  t:lrig(1, 3, 9, {"タマ"})
  t:card{cid = 900001, power = 1000, level = 1, classes = {"精武：遊具"}}
  t:card{cid = 900002, power = 1000, level = 1, classes = {"奏武：遊具"}}
  t:card{cid = 900003, power = 1000, level = 1, classes = {"精像：天使"}}
  t:card{cid = 900004, power = 1000, level = 1, classes = {"精像：悪魔"}}
  t:card{cid = 900005, power = 1000, level = 1, classes = {"奏像：悪魔"}}
  t:card{cid = 900006, type = TYPE_SPELL}  -- 시그니가 아니면 거부
  for cid = 900001, 900006 do t:script(cid, FILTER) end
  t:start{db = true}
  t:put(1, 0, "lrig_center")
  for cid = 900001, 900006 do t:put(cid, 0, "hand") end
  t:expect(t:global("YUGU") == "true true false false false false ")
  t:expect(t:global("SEIZOU") == "false false true true false false ")
end)
