-- WXK10-025 味覚の惑魔　タピピ
-- 【自】《ターン２回》：効果１つによってあなたがカードを１枚以上引いたとき、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－4000する。
-- 【自】：このシグニがアタックしたとき、あなたの手札が対戦相手より少ない場合、対戦相手は手札を１枚デッキの一番下に置く。
-- 【出】《青》：あなたのトラッシュからレベル３以下の青のシグニ１枚を対象とし、それを手札に加える。
-- ライフバースト：対戦相手は自分のシグニ１体を対象とし、それをデッキの一番下に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_DRAW)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(2)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) return ep==tp and (r&REASON_EFFECT)~=0 end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,-4000)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetOperation(function(e,tp,eg)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()<Duel.GetMatchingGroup(nil,1-tp,LOCATION_HAND,0,nil):GetCount() then
      local h=Duel.GetMatchingGroup(nil,1-tp,LOCATION_HAND,0,nil)
      if h:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectCards(1-tp,h,1,1),false) end
    end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetEnaCost("{U}")
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 and x:IsColor(COLOR_BLUE) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e3:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToHand(tc)
    end
  end)
  c:RegisterEffect(e3)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    local x=Duel.SelectTarget(1-tp,Card.IsSigni,1-tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    if x then Duel.SendToDeckBottom(x,false) end
  end)
  c:RegisterEffect(e9)
end
