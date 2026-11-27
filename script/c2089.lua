-- WX05-026 コードアンシエンツ　ネクロノミコ
-- 【自】《ターン１回》：あなたのトラッシュから＜古代兵器＞のシグニ１体が場に出たとき、あなたのトラッシュからカード１枚を対象とし、それを手札に加える。
-- ライフバースト：あなたのデッキからシグニ１枚を探してトラッシュに置く。その後、デッキをシャッフルし、あなたのトラッシュからカード１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()==tp and x:IsPreviousLocation(LOCATION_TRASH) and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KODAIHEIKI)) end)(x) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    local x=aux.Search(tp,Card.IsSigni,1):GetFirst()
    if x then Duel.SendToTrash(x,REASON_EFFECT) end
    aux.ShuffleDeck(tp)
    local tc=Duel.SelectTarget(tp,nil,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if tc then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e2)
end
