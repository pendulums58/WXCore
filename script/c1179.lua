-- WD09-007 白羅星　マーキュリー
-- 【出現条件】《メインフェイズアイコン》レゾナではない＜宇宙＞のシグニ３体をあなたの場からトラッシュに置く
-- 【出】：対戦相手のシグニ１体を対象とし、それをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,3,aux.NonResonaClass(RACE_UCHU))
  -- 코스트가 없는 【出】이라 반드시 고른다(FAQ 3)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
end
