-- WD23-008-A ぷりてぃあーや！Ⅳ
-- 【自】《ターン１回》：あなたの《トラップアイコン》が発動したとき、対戦相手のシグニ１体を対象とし、《青》《青》《青》を支払ってもよい。そうした場合、それをバニッシュする。
-- 【出】《コインアイコン》：あなたのデッキからカードを２枚まで探して【トラップ】としてあなたのシグニゾーンに設置し、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TRAP)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep) return ep==tp end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and Duel.CanPayEna(tp,"{U}{U}{U}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{U}{U}{U}"),REASON_COST)
    if tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetCoinCost(1)
  e2:SetOperation(function(e,tp)
    for tc in aux.Search(tp,nil,2):Iter() do Duel.SetTrap(tc,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e2)
end
