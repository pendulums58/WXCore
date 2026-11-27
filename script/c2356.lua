-- WX09-032 幻獣　コサキ
-- 【常】：あなたが《緑》《緑》《緑》か《緑》《緑》を支払う際、代わりにあなたのエナゾーンからカード名に《オサキ》を含むカード１枚をトラッシュに置いてもよい。（この能力で《無》を支払うことは置き換えられない）
-- 【出】《緑》：あなたのエナゾーンからシグニ１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  -- 【常】 《オサキ》로 《緑》《緑》(《緑》)를 대신 내는 것은 아직(근사 없음)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{G}")
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_ENA,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
end
