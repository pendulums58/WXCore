-- WXK09-033 コードハート　Ｈ・Ｃ・Ｐ・Ｕ
-- 【自】：アタックフェイズの間、このシグニがバニッシュされたとき、《緑》《緑》《緑》を支払ってもよい。そうした場合、あなたのデッキからレベル３以下の緑のシグニ１枚を探してダウン状態で場に出し、デッキをシャッフルする。
-- 【出】：あなたのトラッシュから無色ではないカード１枚を対象とし、それをエナゾーンに置く。
-- ライフバースト：カードを１枚引く。あなたのライフクロスが４枚以下の場合、追加で【エナチャージ１】をする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetCondition(function() return Duel.GetPhase()==PHASE_ATTACK end)
  e1:SetOperation(function(e,tp,eg)
    if not (Duel.CanPayEna(tp,"{G}{G}{G}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{G}{G}{G}"),REASON_COST)
    local x=aux.Search(tp,function(y) return y:IsSigni() and y:GetLevel()<=3 and y:IsColor(COLOR_GREEN) end,1):GetFirst()
    if x then Duel.PutOnField(x,tp,false,true) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:GetColor()~=0 end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToEna(tc)
    end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()<=4 then Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e9)
end
