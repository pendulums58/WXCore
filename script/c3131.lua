-- WX20-042-CB 羅原　アルミ
-- 【出】：あなたのトラッシュから＜原子＞のシグニ３枚までと青のスペル１枚までを対象とし、それらをこのシグニの下に置く。
-- 【自】：あなたのアタックフェイズ開始時、このシグニの下からカード１枚をトラッシュに置いてもよい。そうした場合、カードを１枚引く。
-- 【自】：このシグニがアタックしたとき、シグニ１体を対象とし、このシグニの下からカード２枚をトラッシュに置いてもよい。そうした場合、それをバニッシュする。
-- ライフバースト：シグニ１体を対象とし、あなたの場に＜原子＞のシグニがある場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end,tp,LOCATION_TRASH,0,0,3,nil)
    Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_SPELL) and x:IsColor(COLOR_BLUE) end,tp,LOCATION_TRASH,0,0,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 and h:IsLocation(LOCATION_SZONE) then Duel.PutUnder(h,g) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e2:SetOperation(function(e,tp)
    local u=e:GetHandler():GetUnderGroup()
    if u:GetCount()>0 and Duel.SelectYesNo(tp) and Duel.SendToTrash(Duel.SelectCards(tp,u,1,1),REASON_EFFECT)>0 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ATTACK)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local u=e:GetHandler():GetUnderGroup()
    if u:GetCount()<2 or not Duel.SelectYesNo(tp) then return end
    Duel.SendToTrash(Duel.SelectCards(tp,u,2,2),REASON_EFFECT)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
  end)
  e4:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then Duel.Banish(tc) end end
  end)
  c:RegisterEffect(e4)
end
