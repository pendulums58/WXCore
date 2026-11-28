-- PR-372 羅星　≡デネキュ≡（セレクターズパック Vol.14）
-- 【出】：数字１つを宣言する。その後、あなたのデッキの一番上を公開する。それが宣言した数字と同じレベルのシグニの場合、それを場に出す。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  -- 실제 레벨로 낸다(FAQ 1). 맞지 않으면 덱 위에 그대로(FAQ 2)
  e1:SetOperation(function(e,tp)
    local lv=Duel.AnnounceNumber(tp,0,5)
    local g=Duel.GetDecktopGroup(tp,1)
    local tc=g:GetFirst()
    if not tc then return end
    Duel.RevealCards(g)
    if tc:IsSigni() and (tc:GetLevel()==lv or tc:HasKeyword(EFFECT_ANY_LEVEL)) then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
end
