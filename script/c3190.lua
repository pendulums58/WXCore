-- WX21-027 禁断の知恵　ビネンバウム
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、このシグニとそれをゲームから除外する。
-- 【自】：あなたのアタックフェイズの間、このシグニが場を離れたとき、あなたのデッキの一番上のカードをエナゾーンに置くかカードを１枚引く。
-- ライフバースト：どちらか１つを選ぶ。①ターン終了時まで、対戦相手のセンタールリグは「【常】：アタックできない。」を得る。②あなたのデッキから＜美巧＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    local g=Group.CreateGroup(e:GetHandler())
    if tc and tc:IsRelateToEffect(e) then g:AddCard(tc) end
    Duel.Exclude(g)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_LEAVE_FIELD)
  e2:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp and Duel.GetPhase()==PHASE_ATTACK end)
  e2:SetOperation(function(e,tp)
    if Duel.SelectYesNo(tp) then Duel.EnaCharge(tp,1) else Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e3:SetOperation(function(e,tp)
    if e:GetLabel()==0 then
      local tc=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst()
      if tc then
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_ATTACK)
    e1:SetReset(RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
      end
      return
    end
    aux.SearchToHand(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end,1)
  end)
  c:RegisterEffect(e3)
end
