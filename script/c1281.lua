-- WD16-012 コードアート　Ｍ・Ｗ・Ｏ
-- 【常】：対戦相手の手札が０枚であるかぎり、このシグニはバニッシュされない。
-- 【出】：各プレイヤーは手札を１枚捨てる。
-- 【出】：あなたの手札が２枚より少ない場合、その差の分だけカードを引く。
-- ライフバースト：カードを１枚引く。対戦相手は手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_CANNOT_BANISH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),0,LOCATION_HAND,nil):GetCount()==0 end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local p=Duel.GetTurnPlayer()
    aux.Discard(p,1)
    aux.Discard(1-p,1)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetOperation(function(e,tp)
    local n=2-Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()
    if n>0 then Duel.Draw(tp,n) end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
    aux.Discard(1-tp,1)
  end)
  c:RegisterEffect(e4)
end
