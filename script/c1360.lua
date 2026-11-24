-- WD22-037-UG 死之遊魔　†ルーレット†
-- 【出】：対戦相手のシグニ１体を対象とし、シグニの効果によってこのシグニが場に出た場合、ターン終了時まで、それのパワーを－12000する。
-- 【出】：あなたのトラッシュからシグニ１枚を対象とし、ルリグかアーツの効果によってこのシグニが場に出た場合、それを手札に加える。
-- 【出】《黒》《黒》《黒》：スペルの効果によってこのシグニが場に出た場合、あなたのデッキの一番上のカードをライフクロスに加える。
-- ライフバースト：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－10000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg,ep,ev,re)
    local tc=Duel.GetFirstTarget()
    if re and re:GetHandler():IsSigni() and tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-12000) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg,ep,ev,re)
    local tc,h=Duel.GetFirstTarget(),re and re:GetHandler()
    if h and (h:IsType(TYPE_LRIG) or h:IsType(TYPE_ASSIST_LRIG) or h:IsType(TYPE_ARTS)) and tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetEnaCost("{B}{B}{B}")
  e3:SetOperation(function(e,tp,eg,ep,ev,re)
    if re and re:GetHandler():IsType(TYPE_SPELL) then Duel.SendToLife(Duel.GetDecktopGroup(tp,1)) end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e4:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-10000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e4)
end
