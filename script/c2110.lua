-- WX05-049 中槍　ブルナク
-- 【起】《白》《白》《無》このシグニを場からトラッシュに置く：あなたのデッキから＜アーム＞か＜ウェポン＞のシグニを合計２枚まで探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetEnaCost("{W}{W}{C}")
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_SZONE) end
    Duel.SendToTrash(e:GetHandler(),REASON_COST)
  end)
  e1:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_ARM)) end)(x) or (function(x) return x:IsSigni() and (x:IsClass(0,RACE_WEAPON)) end)(x) end,2)
  end)
  c:RegisterEffect(e1)
end
