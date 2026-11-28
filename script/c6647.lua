-- WXK06-032 デスメタル帝国　デスレックス
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニを２体まで対象とし、ターン終了時まで、それらのパワーをそれぞれ－4000する。このターンにいずれかのプレイヤーがリフレッシュしていた場合、代わりにターン終了時まで、それらのパワーをそれぞれ－12000する。
-- 【起】《ターン１回》《黒×0》：あなたのデッキの上からカードを３枚トラッシュに置く。
-- ライフバースト：カードを１枚引く。あなたのライフクロスが４枚以下の場合、追加で【エナチャージ１】をする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local v=(Duel.GetRefreshCount(0)+Duel.GetRefreshCount(1))>0 and -12000 or -4000
    for x in Duel.GetTargets():Iter() do if x:IsRelateToEffect(e) then aux.AddPower(e,x,v) end end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
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
