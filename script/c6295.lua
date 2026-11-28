-- WXK02-010 ゼノ・カインド
-- あなたのデッキから無色ではないシグニを３枚まで探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and x:GetColor()~=0 end,3)
  end)
  c:RegisterEffect(e1)
end
