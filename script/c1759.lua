-- WDK14-012 炎魔の陽杖　トービエ
-- 【出】《ビートアイコン》［４枚以下］このシグニと他のシグニ１体を【ビート】にする：あなたのトラッシュから《炎魔の陽杖　トービエ》以外の＜悪魔＞のシグニ１枚を対象とし、それを場に出す。
-- （この能力はあなたの【ビート】が４枚以下であるかぎり有効になる。コストの支払いで【ビート】が５枚以上になっても発動する）
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
    local h=e:GetHandler()
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,h)
    if chk==0 then return h:IsLocation(LOCATION_SZONE) and g:GetCount()>0 end
    local x=Duel.SelectCards(tp,g,1,1)
    x:AddCard(h)
    Duel.Beat(x,REASON_COST)
  end)
  -- 영역 지정이 없으면 내 장의 시그니(FAQ 1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return s.akuma(x) and not x:IsCardName(id) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e1)
end
