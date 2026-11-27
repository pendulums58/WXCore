-- WX16-037 隠密の十勇　サイゾウ
-- 【自】：このシグニがライズされたとき、ターン終了時まで、そのシグニは「【常】：バニッシュされない。」を得る。
-- 【自】：このシグニがバニッシュされたとき、あなたのデッキの上からカードを４枚見る。その中から《ライズアイコン》を持つシグニ１枚を公開し手札に加え、残りを好きな順番でデッキの一番下に置く。
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_RISEN)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetRiser()
    if tc and tc:IsLocation(LOCATION_SZONE) then
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_BANISH)
    e1:SetReset(RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_BANISHED)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,4)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local x=Duel.SelectCards(tp,g:Filter(function(x) return x:IsSigni() and x:HasRiseIcon() end,nil),0,1)
    if x:GetCount()>0 then Duel.RevealCards(x) Duel.SendToHand(x) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e3:SetOperation(function(e,tp)
    if e:GetLabel()==0 then Duel.Draw(tp,1) else Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e3)
end
