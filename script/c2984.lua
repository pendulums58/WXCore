-- WX18-030 風魔の頭領　フマコタ
-- 【常】：あなたの場に《ライズアイコン》を持つシグニが２体あるかぎり、このシグニは【アサシン】を得る。
-- 【自】《ターン１回》：このシグニが対戦相手のライフクロス１枚をクラッシュしたとき、あなたの場に《ライズアイコン》を持つシグニがある場合、《赤》《赤》《赤》を支払ってもよい。そうした場合、あなたの手札から《ライズアイコン》を持つシグニ１枚を場に出す。
-- ライフバースト：あなたのトラッシュから《ライズアイコン》を持つシグニを２枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_ASSASSIN)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:HasRiseIcon() end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>=2 end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_CRUSHED)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCondition(function(e,tp,eg,ep) return ep~=tp and Duel.GetCrusher()==e:GetHandler() and Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:HasRiseIcon() end,tp,LOCATION_SZONE,0,nil):GetCount()>0 end)
  e2:SetOperation(function(e,tp)
    if Duel.CanPayEna(tp,"{R}{R}{R}") and Duel.SelectYesNo(tp) then
      Duel.SendToTrash(Duel.SelectEnaCost(tp,"{R}{R}{R}"),REASON_COST)
      local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:HasRiseIcon() end,tp,LOCATION_HAND,0,nil),0,1):GetFirst()
      if x then Duel.PutOnField(x,tp) end
    end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:HasRiseIcon() end,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e3)
end
