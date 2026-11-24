-- WD09-009 羅星　ベガ
-- 【常】：あなたの場にレゾナがあるかぎり、このシグニの基本パワーは15000になる。
-- 【出】《白》：あなたのデッキからレベル２以下の白のシグニ１枚を探して場に出し、デッキをシャッフルする。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それを手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,15000,function(e)
    return Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_RESONA) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0
  end)
  -- 찾지 않았다고 해도 된다(FAQ 1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{W}")
  e2:SetOperation(function(e,tp)
    Duel.ConfirmCards(tp,Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil))
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsColor(COLOR_WHITE) and x:GetLevel()<=2 end,tp,LOCATION_MDECK,0,nil)
    local tc=Duel.SelectCards(tp,g,0,1):GetFirst()
    if tc then Duel.PutOnField(tc,tp) end
    Duel.SendToDeckShuffle(Group.CreateGroup(),tp)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e3)
end
