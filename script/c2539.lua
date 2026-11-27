-- WX12-010 ホワイトメイズ　ホデサパ
-- 【出現条件】 《メインフェイズアイコン》《アタックフェイズアイコン》白のシグニ１枚と黒のシグニ１枚をあなたの手札から捨てる
-- 【常】：対戦相手のシグニは可能ならばアタックしなければならない。
-- 【自】：対戦相手のシグニ１体がアタックしたとき、ターン終了時まで、そのシグニのパワーを－2000する。
-- 【出】：対戦相手のすべてのシグニを好きなように配置し直してもよい。あなたはこの方法で他のシグニゾーンに移動したシグニをアップしてもよい。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,2,Card.IsSigni,LOCATION_HAND,TIMING_MAIN+TIMING_ATTACK,nil,function(g)
    local w,b=false,false
    for x in g:Iter() do
      if x:IsColor(COLOR_WHITE) and not w then w=true elseif x:IsColor(COLOR_BLACK) then b=true end
    end
    return w and b
  end)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_MUST_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(0,LOCATION_SZONE)
  e1:SetTarget(function(e,x) return x:IsSigni() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ATTACK)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()~=tp and x:IsSigni() end)
  e2:SetOperation(function(e,tp,eg)
    local x=eg:GetFirst()
    if x:IsLocation(LOCATION_SZONE) then aux.AddPower(e,x,-2000) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetCode(EVENT_ON_PLAY)
  -- 옮긴 시그니는 모두 업하거나 모두 그대로(FAQ 1)
  e3:SetOperation(function(e,tp)
    if not Duel.SelectYesNo(tp) then return end
    local g=s.rearrange(tp,1-tp)
    if g:GetCount()>0 and Duel.SelectYesNo(tp) then Duel.Up(g) end
  end)
  c:RegisterEffect(e3)
end
-- 시그니를 하나 골라 다른 존으로(차 있으면 맞바꾼다). 옮긴 시그니를 돌려준다
function s.rearrange(tp,p)
  local moved=Group.CreateGroup()
  for _=1,6 do
    local c=Duel.SelectCards(tp,Duel.GetMatchingGroup(Card.IsSigni,p,LOCATION_SIGNI,0,nil),0,1):GetFirst()
    if not c then break end
    local zones={}
    for _,z in ipairs(Duel.GetSigniZones(p)) do if z~=c:GetZone() then zones[#zones+1]=z end end
    local z=Duel.SelectZone(tp,zones)
    if not z then break end
    local o=Duel.GetMatchingGroup(function(x) return x:GetZone()==z end,p,LOCATION_SIGNI,0,nil):GetFirst()
    if Duel.SwapSigni(c,o or z) then
      moved:AddCard(c)
      if o then moved:AddCard(o) end
    end
  end
  return moved
end
