-- WX14-CB03 幻獣　サーバル
-- 【常】：対戦相手のセンタールリグがレベル４以上であるかぎり、このシグニは【ランサー】を得る。
-- 【自】《ターン１回》：このシグニがアタックしたとき、対戦相手のセンタールリグがレベル５の場合、手札から＜空獣＞か＜地獣＞のシグニを１枚捨ててもよい。そうした場合、このシグニをアップする。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_LANCER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) local lc=Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),0,LOCATION_LRIG,nil):GetFirst() return lc and lc:GetLevel()>=4 end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetCountLimit(1)
  e2:SetOperation(function(e,tp)
    local lc=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst()
    if not (lc and lc:GetLevel()==5) then return end
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KUJU) or x:IsClass(0,RACE_CHIJU)) end,tp,LOCATION_HAND,0,nil)
    if g:GetCount()==0 or not Duel.SelectYesNo(tp) then return end
    if Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT+REASON_DISCARD)>0 then local h=e:GetHandler() if h:IsLocation(LOCATION_SZONE) then Duel.Up(h) end end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e3)
end
