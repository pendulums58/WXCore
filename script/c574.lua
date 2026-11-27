-- WX15-033 羅星姫　≡ガーネットスター≡
-- 【自】：このシグニが対戦相手のライフクロス１枚をクラッシュしたとき、《無》を支払ってもよい。そうした場合、あなたのデッキからカード１枚を探して手札に加え、デッキをシャッフルする。
-- 【出】：対戦相手の中央のシグニゾーンにあるシグニ１体を対象とし、対戦相手のライフクロスの枚数があなたより多い場合、それをバニッシュする。
-- ライフバースト：対戦相手は、手札を２枚捨てるかエナゾーンから対象のカード２枚をトラッシュに置かないかぎり、対象の自分のシグニ１体を場からトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_CRUSHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep) return ep~=tp and Duel.GetCrusher()==e:GetHandler() end)
  e1:SetOperation(function(e,tp)
    if Duel.CanPayEna(tp,"{C}") and Duel.SelectYesNo(tp) then
      Duel.SendToTrash(Duel.SelectEnaCost(tp,"{C}"),REASON_COST)
      local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil),1,1)
      if x:GetCount()>0 then Duel.SendToHand(x) end
      aux.ShuffleDeck(tp)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsInZone("signi_center") end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if Duel.GetMatchingGroup(nil,tp,0,LOCATION_LIFE,nil):GetCount()>Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount() then Duel.Banish(tc) end end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    -- 상대: 0 = 패 2장 버리기, 1 = 에나 2장 트래시, 2 = 자기 시그니 1체 트래시
    local o=1-tp
    local can={Duel.GetMatchingGroup(nil,o,LOCATION_HAND,0,nil):GetCount()>=2,Duel.GetMatchingGroup(nil,o,LOCATION_ENA,0,nil):GetCount()>=2}
    local m=Duel.SelectOption(o,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
    if m==0 and can[1] then aux.Discard(o,2) return end
    if m==1 and can[2] then Duel.SendToTrash(Duel.SelectCards(o,Duel.GetMatchingGroup(nil,o,LOCATION_ENA,0,nil),2,2),REASON_EFFECT) return end
    local tc=Duel.SelectTarget(o,Card.IsSigni,o,LOCATION_SZONE,0,1,1,nil):GetFirst()
    if tc then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e3)
end
