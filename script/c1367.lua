-- WD23-005-E アロワナ・パニック
-- 対戦相手のシグニ１体を対象とし、それをデッキの一番上に置く。その後、あなたのセンタールリグが＜エルドラ＞の場合、あなたのライフクロス１枚をクラッシュしてもよい。そうした場合、あなたのデッキの一番上のカードをライフクロスに加える。（ライフバーストはアーツの処理後に発動する）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  -- 대상이 없어도 뒷부분을 처리한다(FAQ 1)
  e1:SetOperation(function(e,tp)
    local tc,lc=Duel.GetFirstTarget(),Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToDeckPosition(tc,1) end
    if not (lc and lc:IsLrigType(LRIG_ELDORA)) or Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()==0 then return end
    if Duel.SelectYesNo(tp) and Duel.Crush(tp,1):GetCount()>0 then Duel.SendToLife(Duel.GetDecktopGroup(tp,1)) end
  end)
  c:RegisterEffect(e1)
end
