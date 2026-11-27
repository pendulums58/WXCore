-- WX17-029 小罠　トレインボム
-- 【自】：対戦相手のターン終了時、このシグニをバニッシュしてもよい。そうした場合、あなたのデッキの上からカードを４枚見て、その中から１枚を【トラップ】としてあなたのシグニゾーンに設置する。残りを好きな順番でデッキの一番下に置く。
-- 【トラップアイコン】：あなたのトラッシュからカード１枚を対象とし、《無》を支払ってもよい。そうした場合、このカードはそれのトラップ能力を得て、その能力を発動する。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TURN_END)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if not Duel.SelectYesNo(tp) or Duel.Banish(h)==0 then return end
    local g=Duel.GetDecktopGroup(tp,4)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local x=Duel.SelectCards(tp,g,1,1):GetFirst()
    if x then Duel.SetTrap(x,tp) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
  end)
  c:RegisterEffect(e1)
  -- 【トラップアイコン】 「トラッシュのカードのトラップ能力を得て発動」은 아직(근사 없음)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_TRAP)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetOperation(function(e,tp)
    
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e3)
end
