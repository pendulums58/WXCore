-- WX21-046 コードアート　†Ｈ・Ｐ・Ｌ†
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、あなたのトラッシュからそれぞれコストの合計が異なるスペル３枚をデッキに加えてシャッフルする。そうした場合、カードを１枚引き、ターン終了時まで、それのパワーを－8000する。
-- ライフバースト：あなたのデッキからスペル１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
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
    local g=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_SPELL) end,tp,LOCATION_TRASH,0,nil)
    Duel.SetSelectCheck(function(sg) if sg:GetCount()==0 then return true end local seen={} for x in sg:Iter() do if seen[x:GetCostTotal()] then return false end seen[x:GetCostTotal()]=true end return sg:GetCount()==3 end)
    local pick=Duel.SelectCards(tp,g,0,3)
    if pick:GetCount()<3 then return end
    Duel.SendToDeckShuffle(pick,tp)
    Duel.Draw(tp,1)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-8000) end  -- [まで]
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsType(TYPE_SPELL) end,1)
  end)
  c:RegisterEffect(e2)
end
