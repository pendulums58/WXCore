-- WX04-071 羅石　トパズ
-- 【起】《赤》このシグニを場からトラッシュに置く：あなたのデッキからコストの合計が１以下の赤のスペル１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetEnaCost("{R}")
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_SZONE) end
    Duel.SendToTrash(e:GetHandler(),REASON_COST)
  end)
  e1:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsType(TYPE_SPELL) and x:IsColor(COLOR_RED) and x:GetCostTotal()<=1 end,1)
  end)
  c:RegisterEffect(e1)
end
