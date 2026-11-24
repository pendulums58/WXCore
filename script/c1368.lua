-- WD23-007-E 青幻水　リヴァイア
-- 【出現条件】《メインフェイズアイコン》レゾナではない＜水獣＞のシグニ３体をあなたの場からトラッシュに置く
-- 【自】：このシグニがアタックしたとき、あなたの手札が７枚より少ない場合、その差の分だけカードを引く。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,3,aux.NonResonaClass(RACE_SUIJU))
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local n=7-Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()
    if n>0 then Duel.Draw(tp,n) end
  end)
  c:RegisterEffect(e1)
end
