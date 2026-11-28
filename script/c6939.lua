-- WXK09-066 深淵の蒼天　エンキ
-- 【出】：対戦相手のレベル３以下のシグニ１体を対象とし、それを凍結する。あなたのトラッシュに＜天使＞のシグニが１５枚以上ある場合、代わりにそれをデッキの一番上に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      if Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_TENSHI) end,tp,LOCATION_TRASH,0,nil):GetCount()>=15 then Duel.SendToDeckPosition(tc,1) else Duel.Freeze(tc) end
    end
  end)
  c:RegisterEffect(e1)
end
