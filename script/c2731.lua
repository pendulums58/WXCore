-- WX14-071 コードアンチ　マイギリ
-- 【自】：このカードがデッキからトラッシュに置かれたとき、このカードをトラッシュから場に出してもよい。
-- 【自】：対戦相手のターンの間、このシグニがバニッシュされたとき、対戦相手のシグニ１体を対象とし、あなたのセンタールリグが黒の場合、《黒》を支払ってもよい。そうした場合、ターン終了時まで、それのパワーを－7000する。
local s,id=GetID()
function s.initial_effect(c)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e9:SetDescription(aux.Ability(id,0))
  e9:SetCode(EVENT_TO_TRASH)
  e9:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_MDECK) end)
  e9:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_TRASH) and Duel.SelectYesNo(tp) then Duel.PutOnField(h,tp) end
  end)
  c:RegisterEffect(e9)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_BANISHED)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    if not (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsColor(COLOR_BLACK) end)() then return end
    if not (Duel.CanPayEna(tp,"{B}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{B}"),REASON_COST)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-7000) end
  end)
  c:RegisterEffect(e1)
end
