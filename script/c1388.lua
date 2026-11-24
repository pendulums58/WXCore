-- WD23-032-A 超罠　タコツボ
-- 【自】《ターン１回》：あなたの《トラップアイコン》が発動したとき、シグニ１体を対象とし、それをアップするかダウンする。
-- 【自】《ターン１回》：あなたのシグニ１体がアタックしたとき、あなたのデッキの上からカードを２枚見る。その中からカード１枚を【トラップ】としてあなたのシグニゾーンに設置してもよい。残りを好きな順番でデッキの一番上に戻す。
-- 【トラップアイコン】：対戦相手のシグニ１体を対象とし、それをダウンし、カードを１枚引く。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それをダウンし凍結する。カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TRAP)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep) return ep==tp end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then 
      if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then Duel.Up(tc) else Duel.Down(tc) end
     end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCondition(function(e,tp,eg,ep) return ep==tp and eg:GetFirst():IsSigni() end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,2)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local tc=Duel.SelectCards(tp,g,0,1):GetFirst()
    if tc then Duel.SetTrap(tc,tp) end
    local rest=g:Filter(function(x) return x:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then aux.ToDeckTopInOrder(tp,rest) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_TRAP)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Down(tc) end
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  -- 대상이 없어도 뽑는다(FAQ 2)
  e4:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.Down(tc)
      Duel.Freeze(tc)
    end
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e4)
end
