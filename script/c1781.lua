-- WDK16-01H 樋口楓　レベル４
-- 【自】：あなたのターン終了時、このターンに対戦相手のシグニがバニッシュされていた場合、登録者数を１０万人得る。
-- 【出】：対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- 【起】《ゲーム１回》＃でろおんえあ《赤×0》：あなたの登録者数が８０万人を達成している場合、対戦相手のすべてのシグニをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TURN_END)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp and Duel.GetBanishedCount(1-tp)>0 end)
  e1:SetOperation(function(e,tp)
    Duel.AddSubscribers(tp,10)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(1,true)
  e3:SetOperation(function(e,tp)
    if Duel.GetSubscribers(tp)>=80 then
      local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
      if g:GetCount()>0 then Duel.Banish(g) end
    end
  end)
  c:RegisterEffect(e3)
end
