-- WDK14-013 炎魔の聖墓　ナーキル
-- 【出】《ビートアイコン》［４枚以下］トラッシュから＜悪魔＞のシグニ１枚を【ビート】にする：この方法であなたの【ビート】が４枚になった場合、カードを１枚引く。
-- （この能力はあなたの【ビート】が４枚以下であるかぎり有効になる）
-- （【ビート】はターン終了時まであなたが持ち、その後トラッシュに置かれる）
local s,id=GetID()
s.akuma=aux.ClassFilter(0,RACE_AKUMA)  -- ＜悪魔＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  -- 《ビートアイコン》［４枚以下］: 트리거할 때 본다. 코스트로 5장 이상이 돼도 발동한다
  e1:SetCondition(aux.BeatCon(function(g) return g:GetCount()<=4 end))
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.akuma,tp,LOCATION_TRASH,0,nil)
    if chk==0 then return g:GetCount()>0 end
    Duel.Beat(Duel.SelectCards(tp,g,1,1),REASON_COST)
  end)
  -- 코스트를 낸 뒤에 센다(FAQ 1)
  e1:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_BEAT,0,nil):GetCount()==4 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
end
