-- WXK09-017 コード・ピルルク　ｋＶ
-- 【出】：あなたのルリグデッキに《改造素材》１枚を加える。
-- 【出】《緑》：《コインアイコン》を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    Duel.AddCraft(6974,tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{G}")
  e2:SetOperation(function(e,tp,eg)
    Duel.AddCoin(tp,1)
  end)
  c:RegisterEffect(e2)
end
