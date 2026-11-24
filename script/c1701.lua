-- WDK10-014 幻竜　ベルゼブブ
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、手札から＜龍獣＞のシグニを１枚捨ててもよい。そうした場合、ターン終了時まで、それのパワーを－8000する。
-- （パワーが０以下のシグニはルールによってバニッシュされる）
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
s.ryu=aux.ClassFilter(0,RACE_RYUJU)  -- ＜龍獣＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    local g=Duel.SelectDiscard(tp,0,1,s.ryu)
    if g:GetCount()==0 or Duel.SendToTrash(g,REASON_EFFECT+REASON_DISCARD)==0 then return end
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-8000) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
