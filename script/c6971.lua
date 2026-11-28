-- WXK09-098 菓子の童話　ヘンゼル
-- 【出】《黒》：あなたのデッキからレベル２の黒のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{B}")
  e1:SetOperation(function(e,tp,eg)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and x:GetLevel()==2 and x:IsColor(COLOR_BLACK) end,1)
  end)
  c:RegisterEffect(e1)
end
