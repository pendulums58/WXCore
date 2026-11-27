-- WX22-044 幻竜　＃ラドーン＃
-- 【自】：このシグニがアタックしたとき、あなたのシグニ１体を対象とし、あなたの手札から＜龍獣＞のシグニを１枚公開してもよい。そうした場合、ターン終了時まで、それのパワーを＋5000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end,tp,LOCATION_HAND,0,nil)
    if g:GetCount()==0 or not Duel.SelectYesNo(tp) then return end
    Duel.RevealCards(Duel.SelectCards(tp,g,1,1))
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,5000) end  -- [まで]
  end)
  c:RegisterEffect(e1)
end
