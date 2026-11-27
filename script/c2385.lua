-- WX10-006 緑肆ノ遊　メリゴラン
-- 【出現条件】 《メインフェイズアイコン》レゾナではない＜遊具＞のシグニ３体をあなたの場からトラッシュに置く
-- 【自】：このシグニがアタックしたとき、あなたのエナゾーンからカード１枚を対象とし、それを手札に加えてもよい。
-- 【自】：このシグニがバニッシュされたとき、あなたのエナゾーンからカードを２枚まで対象とし、それらを手札に加えてもよい。
-- 【出】：あなたのデッキの上からカードを２枚エナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,3,aux.NonResonaClass(RACE_YUGU))
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local tc=Duel.SelectTarget(tp,nil,tp,LOCATION_ENA,0,0,1,nil):GetFirst()
    if tc then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_BANISHED)
  e2:SetOperation(function(e,tp)
    local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ENA,0,0,2,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetOperation(function(e,tp)
    Duel.EnaCharge(tp,2)
  end)
  c:RegisterEffect(e3)
end
