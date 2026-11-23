-- WD09-011 羅星　アルタイル
-- 【出】《白》：あなたのデッキから《羅星　ベガ》を探して公開し手札に加え、デッキをシャッフルする。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
local VEGA=1181
function s.initial_effect(c)
  -- 없으면 섞기만 한다(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{W}")
  e1:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:GetCode()==VEGA end,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e2)
end
