-- WXK09-057 彷徨変異の大悪　スユラギ
-- 【自】：このシグニがアタックしたとき、あなたか対戦相手のデッキの上からカードを３枚トラッシュに置く。
-- 【出】：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－3000する。あなたの場に傀儡状態のシグニがある場合、代わりにターン終了時まで、それのパワーを－7000する。
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－3000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp,eg)
    local p=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))==0 and tp or 1-tp
    local g=Duel.GetDecktopGroup(p,3)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsPuppet() end,tp,LOCATION_SZONE,0,nil):GetCount()>0 and -7000 or -3000)
    end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e9:SetOperation(function(e,tp,eg)
    if e:GetLabel()==0 then Duel.Draw(tp,1) return end
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then aux.AddPower(e,tc,-3000) end
  end)
  c:RegisterEffect(e9)
end
