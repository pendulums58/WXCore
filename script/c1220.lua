-- WD12-007 緑肆ノ遊　カラシャ
-- 【出現条件】《メインフェイズアイコン》レゾナではない＜遊具＞のシグニ３体をあなたの場からトラッシュに置く
-- 【自】：このシグニが場を離れたとき、あなたのルリグデッキからレベル３以下の＜遊具＞のレゾナ１枚を出現条件を無視して場に出す。
-- 【出】《緑×0》：あなたのエナゾーンからシグニ１枚を対象とし、それを場に出す。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,3,aux.NonResonaClass(RACE_YUGU))
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_LEAVE_FIELD)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x)
      return x:IsType(TYPE_RESONA) and x:IsClass(0,RACE_YUGU) and x:GetLevel()<=3
    end,tp,LOCATION_LDECK,0,nil)
    if g:GetCount()==0 then return end
    local tc=Duel.SelectCards(tp,g,1,1):GetFirst()
    if tc then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e1)
  -- 코스트(0)가 있는 【出】이라 발동하지 않아도 된다(FAQ 1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_ENA,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e2)
end
