-- WXK01-051 絶縁の豪爪
-- 対戦相手のライフクロスが２枚以上ある場合、対戦相手のライフクロス１枚をクラッシュする。あなたの場にドライブ状態のシグニがある場合、この効果でクラッシュされたカードのライフバーストは発動しない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    if Duel.GetMatchingGroup(nil,tp,0,LOCATION_LIFE,nil):GetCount()<2 then return end
    local drive=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsDrive() end,tp,LOCATION_SZONE,0,nil):GetCount()>0
    Duel.Crush(1-tp,1,false,drive)
  end)
  c:RegisterEffect(e1)
end
