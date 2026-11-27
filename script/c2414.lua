-- WX10-043 幻水　シャチ
-- 【起】《ダウン》アップ状態の＜水獣＞のシグニ１体をダウンする：カードを２枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local h=e:GetHandler()
    local g=Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_SUIJU)) end)(x) and x:IsUp() end,tp,LOCATION_SZONE,0,h)
    if chk==0 then return h:IsUp() and g:GetCount()>0 end
    Duel.Down(h,REASON_COST)
    Duel.Down(Duel.SelectCards(tp,g,1,1),REASON_COST)
  end)
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,2)
  end)
  c:RegisterEffect(e1)
end
