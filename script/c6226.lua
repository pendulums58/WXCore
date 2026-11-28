-- WXK01-043 幻怪姫　ユニカーン
-- 【自】《ターン１回》：あなたが緑のアーツを使用したとき、【エナチャージ１】をする。
-- 【自】：このシグニが対戦相手のシグニ１体をバニッシュしたとき、あなたのルリグトラッシュから緑のアーツ１枚を対象とし、《緑》《緑》を支払ってもよい。そうした場合、それをルリグデッキに加える。
-- ライフバースト：カードを１枚引く。あなたのライフクロスが４枚以下の場合、追加で【エナチャージ１】をする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_USE_CARD)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep) local x=eg:GetFirst() return ep==tp and x:IsType(TYPE_ARTS) and x:IsColor(COLOR_GREEN) end)
  e1:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_BANISHED)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg,ep) return ep~=tp and Duel.GetBanisher()==e:GetHandler() end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_ARTS) and x:IsColor(COLOR_GREEN) end,tp,LOCATION_LTRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.CanPayEna(tp,"{G}{G}") and Duel.SelectYesNo(tp) then
      Duel.SendToTrash(Duel.SelectEnaCost(tp,"{G}{G}"),REASON_COST)
      if tc:IsLocation(LOCATION_LTRASH) then Duel.SendToLrigDeck(tc) end
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
