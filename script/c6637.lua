-- WXK06-022 ウェアラブル・デッド
-- このアーツの使用コストはあなたの場にあるシグニ１体につき《黒×1》減る。
-- ターン終了時まで、対象の対戦相手のシグニ１体のパワーを－12000する。あなたのトラッシュから対象のシグニ１枚を手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    for x in Duel.GetTargets():Iter() do
      if x:IsRelateToEffect(e) then
        if x:IsLocation(LOCATION_SZONE) then aux.AddPower(e,x,-12000) else Duel.SendToHand(x) end
      end
    end
  end)
  c:RegisterEffect(e1)
  aux.SetCostBy(e1,function(e,tp,base) return Duel.ReduceCost(base,"{B}",Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):GetCount()) end)
end
