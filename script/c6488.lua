-- WXK04-032 コードオーダー　アイスパフィ
-- 【自】：このシグニが場を離れたとき、対戦相手は以下の２つから１つを選び、対戦相手はそれを行う。
-- ①カードを２枚引く。
-- ②手札からシグニ１枚を場に出す。
-- 【出】《青》：対戦相手のシグニ１体を対象とし、それをデッキの一番上に置く。
-- ライフバースト：カードを１枚引く。あなたのライフクロスが４枚以下の場合、追加で【エナチャージ１】をする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_LEAVE_FIELD)
  e1:SetOperation(function(e,tp,eg)
    local p=1-tp
    local h=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_SIGNI) end,p,LOCATION_HAND,0,nil)
    if Duel.SelectOption(p,aux.Stringid(id,0),aux.Stringid(id,1))==0 or h:GetCount()==0 then Duel.Draw(p,2) return end
    Duel.PutOnField(Duel.SelectCards(p,h,1,1):GetFirst(),p)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{U}")
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToDeckPosition(tc,1)
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
