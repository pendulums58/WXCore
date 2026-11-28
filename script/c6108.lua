-- WXEX1-74 コードアンチ　レザディ
-- 【自】：このカードがデッキからトラッシュに置かれたとき、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーをあなたのセンタールリグのレベル１につき－1000する。
-- 【出】：あなたのデッキから＜古代兵器＞のシグニ１枚を探してトラッシュに置き、デッキをシャッフルする。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetCondition(function(e,tp) return e:GetHandler():IsPreviousLocation(LOCATION_MDECK) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    local l=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    local lv=l and l:GetLevel() or 0
    if tc and tc:IsRelateToEffect(e) and lv>0 then aux.AddPower(e,tc,-1000*lv) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local d=Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil)
    Duel.ConfirmCards(tp,d)
    local pick=Duel.SelectCards(tp,d:Filter(aux.ClassFilter(0,RACE_KODAIHEIKI),nil),1,1)
    if pick:GetCount()>0 then Duel.SendToTrash(pick,REASON_EFFECT) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e9)
end
