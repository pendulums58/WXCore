-- WXK10-030 山羊座軍の童話　セブンゴーツ
-- 【出】《黒》：あなたのデッキの上からカードを４枚公開する。その後、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーをこの方法で公開されたシグニのレベルの合計１につき－1000する。公開したカードをトラッシュに置く。
-- 【自】：このカードがデッキからトラッシュに置かれたとき、《黒》を支払ってもよい。そうした場合、このカードをトラッシュから手札に加える。
-- ライフバースト：あなたのデッキの上からカードを３枚トラッシュに置く。その後、あなたのトラッシュからシグニ１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{B}")
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,4)
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local n=0
    for x in g:Iter() do if x:IsSigni() then n=n+x:GetLevel() end end
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc and n>0 then aux.AddPower(e,tc,-1000*n) end
    Duel.SendToTrash(g,REASON_EFFECT)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_TO_TRASH)
  e2:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_MDECK) end)
  e2:SetOperation(function(e,tp,eg)
    if not (Duel.CanPayEna(tp,"{B}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{B}"),REASON_COST)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_TRASH) then Duel.SendToHand(h) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    local x=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if x then Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e9)
end
