-- WXK08-066 コードＶＬ　夕陽リリ
-- 【出】：あなたのデッキの上からカードを３枚見る。それらを好きな順番でデッキの一番上に戻す。その後、あなたの登録者数が１００万人を達成している場合、【エナチャージ１】をする。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()>1 then Duel.ConfirmCards(tp,g) aux.ToDeckTopInOrder(tp,g) end
    if Duel.GetSubscribers(tp)>=100 then Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e9)
end
