-- WXK03-076 元老の議員　ブルータス
-- 【出】：０～５の数字１つを宣言する。あなたのデッキの上から宣言した数字に等しい枚数のカードをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    local n=Duel.AnnounceNumber(tp,0,5)
    local g=Duel.GetDecktopGroup(tp,n)
    if n>0 and g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
end
