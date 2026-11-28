-- WXK10-083 コードアート　Ｔ・Ｍ・Ｂ
-- 【出】：このターンと次のターンの間、対戦相手の効果によって、あなたのエナゾーンにあるカードはトラッシュに移動しない。
-- 【出】：あなたの手札から無色ではないカードを１枚までエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  -- 「エナゾーンにあるカードはトラッシュに移動しない」는 아직
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    -- 아직
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp,eg)
    local h=Duel.GetMatchingGroup(function(x) return x:GetColor()~=0 end,tp,LOCATION_HAND,0,nil)
    if h:GetCount()>0 then local g=Duel.SelectCards(tp,h,0,1) if g:GetCount()>0 then Duel.SendToEna(g) end end
  end)
  c:RegisterEffect(e2)
end
