-- WXEX1-41 超罠　ビリリガン
-- 【自】《ターン１回》：あなたの【トラップ】１つが設置されたとき、カードを１枚引くか【エナチャージ１】をする。
-- 【出】：対戦相手のシグニ１体を対象とし、あなたのデッキの一番上のカードをトラッシュに置く。そのカードが《トラップアイコン》を持つカードの場合、それをバニッシュする。
-- 【トラップアイコン】：《青》を支払ってもよい。そうした場合、対戦相手のダウン状態のすべてのシグニをバニッシュする。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それをダウンする。カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  -- トラップ設置イベントはまだ(トラップ発動時で近似)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TRAP)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep) return ep==tp end)
  e1:SetOperation(function(e,tp)
    if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then Duel.Draw(tp,1) else Duel.EnaCharge(tp,1) end
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
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    local top=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not top then return end
    Duel.SendToTrash(top,REASON_EFFECT)
    if top:HasTrapIcon() and tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_TRAP)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetOperation(function(e,tp)
    if not Duel.CanPayEna(tp,"{U}") or not Duel.SelectYesNo(tp) then return end
    local g=Duel.SelectEnaCost(tp,"{U}")
    if g:GetCount()>0 and Duel.SendToTrash(g,REASON_COST)>0 then
      local dg=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsDown() end,tp,0,LOCATION_SZONE,nil)
      if dg:GetCount()>0 then Duel.Banish(dg) end
    end
  end)
  c:RegisterEffect(e3)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e9:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Down(tc) end
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e9)
end
