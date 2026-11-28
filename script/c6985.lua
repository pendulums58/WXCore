-- WXK10-011 弾丸雨注
-- 以下の３つから２つまで選ぶ。あなたのセンタールリグが＜緑子＞の場合、代わりに３つまで選ぶ。
-- ①対戦相手のシグニ１体を対象とし、それをエナゾーンに置く。
-- ②あなたのエナゾーンからシグニを２枚まで対象とし、それらを場に出す。ターン終了時まで、あなたのすべてのシグニのパワーを＋5000する。
-- ③次の対戦相手のターンの間、対戦相手は中央のシグニゾーンにあるシグニでアタックできない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    for _,m in ipairs(Duel.SelectModes(tp,1,((function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_MIDORIKO) end)()) and 3 or 2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) do
      if m==0 then
        local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
        if not tc then return end
        Duel.SendToEna(tc)
      elseif m==1 then
        for x in Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_ENA,0,0,2,nil):Iter() do Duel.PutOnField(x,tp) end
        for x in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do aux.AddPower(e,x,5000) end
      elseif m==2 then
        -- 「次の対戦相手のターンの間…中央のシグニゾーンにあるシグニでアタックできない」
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCondition(function() return Duel.GetTurnPlayer()~=tp end)
        e1:SetCode(EFFECT_CANNOT_ATTACK)
        e1:SetTargetRange(0,LOCATION_SZONE)
        e1:SetTarget(function(e,x) return x:IsInZone("signi_center") end)
        e1:SetReset(RESET_MY_TURN)
        Duel.RegisterEffect(e1,tp)
      end
    end
  end)
  c:RegisterEffect(e1)
end
