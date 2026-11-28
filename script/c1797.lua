-- WDK16-06S コードＶＬ　笹木咲
-- 【出】：あなたの場にカード名に《凛》を含むセンタールリグがいる場合、対戦相手は手札を１枚捨てる。あなたの登録者数が１００万人を達成している場合、代わりに対戦相手の手札を１枚見ないで選び、捨てさせる。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それをダウンする。対戦相手は手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    local named=lc and aux.NameHas(lc,"凛")
    if not named then return end
    local h=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    if Duel.GetSubscribers(tp)>=100 then
      -- 「見ないで選び」: 뒷면으로 고른다
      if h:GetCount()>0 then Duel.SendToTrash(Duel.SelectCards(tp,h,1,1),REASON_EFFECT+REASON_DISCARD) end
    else
      aux.Discard(1-tp,1)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Down(tc) end
    aux.Discard(1-tp,1)
  end)
  c:RegisterEffect(e2)
end
