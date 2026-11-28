-- WXEX1-64 幻蟲　モルフォチョウ
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、手札から＜凶蟲＞のシグニを１枚捨ててもよい。ターン終了時まで、それのパワーをこの方法で捨てたシグニのレベル１につき－2000する。
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
    local pool=Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_KYOUCHU),tp,LOCATION_HAND,0,nil)
    if pool:GetCount()==0 or not Duel.SelectYesNo(tp) then return end
    local d=Duel.SelectDiscard(tp,1,1,aux.ClassFilter(0,RACE_KYOUCHU)):GetFirst()
    if not d then return end
    local lv=aux.RefLevel(tp,d)
    if Duel.SendToTrash(d,REASON_DISCARD+REASON_EFFECT)>0 and tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,-2000*lv)
    end
  end)
  c:RegisterEffect(e1)
end
