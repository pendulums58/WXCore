-- WX20-065 コードアート　Ｄ・Ｃ
-- 【自】：あなたのターン終了時、あなたの手札が１枚以下の場合、カードを１枚引く。あなたのトラッシュにカード名に《Ｃ・Ｍ・Ｒ》を含むカードがある場合、代わりにカードを２枚引く。
-- 【出】手札を２枚捨てる：対戦相手のレベル３以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TURN_END)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp and Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()<=1 end)
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,(Duel.GetMatchingGroup(function(x) return aux.NameHas(x,"Ｃ・Ｍ・Ｒ") end,tp,LOCATION_TRASH,0,nil):GetCount()>0) and 2 or 1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetCost(aux.DiscardCost(2,nil))
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
end
