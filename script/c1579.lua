-- WDK01-013 コードライド　トッキュウ
-- 【常】：あなたの場にドライブ状態のシグニがあるかぎり、このシグニのパワーは＋4000される。
-- （ルリグが乗っているシグニはドライブ状態である）
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 자신이 ドライブ状態여도(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e)
    return Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsDrive() end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0
  end)
  e1:SetValue(4000)
  c:RegisterEffect(e1)
end
