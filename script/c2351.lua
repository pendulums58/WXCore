-- WX09-027 羅石　オリハルティア
-- 【常】：あなたの場にある《羅石　オリハルティア》以外のシグニの「対戦相手のパワー7000以下のシグニ１体を対象とし、それをバニッシュする。」は「対戦相手のパワー15000以下のシグニ１体を対象とし、それをバニッシュする。」になり、「対象の対戦相手のパワー7000以下のシグニ１体をバニッシュする。」は「対象の対戦相手のパワー15000以下のシグニ１体をバニッシュする。」になる。
-- 【出】：対戦相手のパワー7000以下のシグニ１体を対象とし、あなたのトラッシュにカード名に《アダマスフィア》を含むシグニがある場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 다른 시그니의 「パワー7000以下…バニッシュ」를 15000으로(aux.BanishPowerTarget를 쓰는 것만)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(aux.BanishPowerTarget(7000))
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if Duel.GetMatchingGroup(function(x) return x:IsSigni() and aux.NameHas(x,"アダマスフィア") end,tp,LOCATION_TRASH,0,nil):GetCount()>0 then Duel.Banish(tc) end end
  end)
  c:RegisterEffect(e1)
end
