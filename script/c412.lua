-- WD01-011 篭手　トレット
-- 【出】《白》：あなたのデッキから《甲冑　ローメイル》１枚を探して公開し手札に加え、デッキをシャッフルする。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
local ROMAIL=410  -- 甲冑　ローメイル
function s.initial_effect(c)
  -- 코스트가 있는 【出】은 쓰지 않아도 된다(FAQ 3)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{W}")
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e2)
end
-- 있어도 찾지 않았다고 하고 섞기만 해도 된다(FAQ 4)
function s.op(e,tp)
  aux.SearchToHand(tp,function(x) return x:GetCode()==ROMAIL end,1)
end
