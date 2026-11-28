-- WXK07-036 羅原　Tan
-- 【自】：このシグニがアタックしたとき、対戦相手のレベル２以下のシグニ１体を対象とし、あなたのライフクロスが対戦相手より多い場合、《赤》を支払ってもよい。そうした場合、それをバニッシュする。
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②対戦相手のパワー3000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=2 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()>Duel.GetMatchingGroup(nil,1-tp,LOCATION_LIFE,0,nil):GetCount()) then return end
    if not (Duel.CanPayEna(tp,"{R}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{R}"),REASON_COST)
    Duel.Banish(tc)
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e9:SetOperation(function(e,tp,eg)
    if e:GetLabel()==0 then Duel.Draw(tp,1) return end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=3000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e9)
end
