-- WDK11-001 エマ　レベル４
-- 【自】：このルリグがアタックしたとき、あなたの場に《ＧＦ　ノーマン＆レイ》がいる場合、《白》を支払ってもよい。その後、この方法で《白》を支払った場合、あなたのトラッシュから＜英知＞のシグニ１枚を対象とし、それを手札に加える。
-- 【自】：このルリグがアタックしたとき、あなたの場に＜英知＞のシグニがある場合、カードを１枚引く。
-- 【出】：あなたのルリグデッキから《ＧＦ　ノーマン＆レイ》１枚を場に出す。
local s,id=GetID()
s.eichi=aux.ClassFilter(0,RACE_EICHI)  -- ＜英知＞のシグニ
function s.initial_effect(c)
  -- 《白》을 내고 나서 고르므로 낸 카드도 된다(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(function(x) return x:IsCardName(1713) end,tp,LOCATION_KEY,0,nil):GetCount()==0 then return end
    if not (Duel.CanPayEna(tp,"{W}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{W}"),REASON_COST)
    local tc=Duel.SelectTarget(tp,s.eichi,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if tc then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(s.eichi,tp,LOCATION_SZONE,0,nil):GetCount()>0 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  -- 루리그 덱은 비공개라 내지 않아도 된다
  e3:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsCardName(1713) end,tp,LOCATION_LDECK,0,nil)
    local tc=Duel.SelectCards(tp,g,0,1):GetFirst()
    if tc then Duel.PutKey(tc,tp) end
  end)
  c:RegisterEffect(e3)
end
