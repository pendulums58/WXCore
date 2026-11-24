-- WDK10-007 サーベイジ・イリュージョン
-- ターン終了時まで、対象の対戦相手のシグニ１体のパワーを－8000する。対戦相手の場にキーがある場合、あなたのトラッシュから対象の＜龍獣＞のシグニ１枚を場に出す。そのシグニの【出】能力は発動しない。
local s,id=GetID()
s.ryu=aux.ClassFilter(0,RACE_RYUJU)  -- ＜龍獣＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 키가 없어도 둘 다 고른다(FAQ 3)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
    Duel.SelectTarget(tp,s.ryu,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local opp,mine
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then
        if tc:IsLocation(LOCATION_TRASH) then mine=tc else opp=tc end
      end
    end
    if opp then aux.AddPower(e,opp,-8000) end  -- [まで] ターン終了時まで
    if mine and Duel.GetMatchingGroup(nil,tp,0,LOCATION_KEY,nil):GetCount()>0 then Duel.PutOnField(mine,tp,true) end
  end)
  c:RegisterEffect(e1)
end
