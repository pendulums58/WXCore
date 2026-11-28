-- WXK10-043 雪英の迷形　ケッショウ
-- 【出】：各プレイヤーは、カードを１枚引き手札を１枚デッキの一番下に置く。
-- 【起】《青》《青》このシグニを場からデッキの一番下に置く：対戦相手のレベル３以下のシグニ１体を対象とし、それをデッキの一番下に置く。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    for _,p in ipairs({tp,1-tp}) do
      Duel.Draw(p,1)
      local h=Duel.GetMatchingGroup(nil,p,LOCATION_HAND,0,nil)
      if h:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectCards(p,h,1,1),false) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetEnaCost("{U}{U}")
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_SZONE) end
    Duel.SendToDeckBottom(e:GetHandler(),false)
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToDeckBottom(tc,false)
    end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e9)
end
