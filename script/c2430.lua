-- WX10-062 轟砲　アムスト
-- 【出】：あなたの場に他の＜ウェポン＞と＜アーム＞のシグニがある場合、対象の対戦相手のパワー7000以下のシグニ１体をバニッシュする。
-- ライフバースト：対戦相手のパワー5000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(aux.BanishPowerTarget(7000))
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then local h=e:GetHandler()
        if Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_WEAPON)) end,tp,LOCATION_SZONE,0,h):GetCount()>0 and Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_ARM)) end,tp,LOCATION_SZONE,0,h):GetCount()>0 then Duel.Banish(tc) end end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(aux.BanishPowerTarget(5000))
  e2:SetOperation(aux.BanishOp)
  c:RegisterEffect(e2)
end
