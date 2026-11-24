-- WD23-021-E 幻水姫　ダイホウイカ
-- 【自】：あなたのアタックフェイズ開始時、カードを２枚引く。
-- 【自】：あなたのターン終了時、あなたは手札を１枚捨てる。
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、手札を好きな枚数捨ててもよい。ターン終了時まで、それのパワーをこの方法で捨てた手札１枚につき－6000する。
-- ライフバースト：カードを１枚引く。その後、あなたの手札が４枚以下の場合、追加でカードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep) return ep==tp end)
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,2)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_TURN_END)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg,ep) return ep==tp end)
  e2:SetOperation(function(e,tp)
    aux.Discard(tp,1)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ATTACK)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local n=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()
    if n==0 then return end
    local g=Duel.SelectDiscard(tp,0,n)
    if g:GetCount()==0 then return end
    n=Duel.SendToTrash(g,REASON_EFFECT+REASON_DISCARD)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-6000*n) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()<=4 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e4)
end
