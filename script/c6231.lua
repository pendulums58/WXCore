-- WXK01-048 コードライド　オートバイ
-- 【ドライブ自】：このシグニがアタックしたとき、対戦相手のパワー1000以下のすべてのシグニをバニッシュする。
-- （【ドライブ自】はそのシグニがドライブ状態であるかぎり有効である）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  -- 【ドライブ自】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetCondition(function(e) return e:GetHandler():IsDrive() end)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetPower()<=1000 end,tp,0,LOCATION_SZONE,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e1)
end
