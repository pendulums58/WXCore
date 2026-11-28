-- PR-461 風月の巫女　タマヨリヒメ（コロコロアニキ2018年春号 付録）
-- 【グロウ】あなたのライフクロスが０枚である
-- 【常】：【ダブルクラッシュ】
-- 【自】：このルリグがアタックしたとき、あなたのシグニ１体を場からトラッシュに置いてもよい。そうした場合、このルリグをアップする。
-- 【出】：あなたのデッキからシグニを３枚まで探して場に出し、デッキをシャッフルする。
-- （【好】：生焼け状態であるかぎり、このカードは裏返しにできない。）
local s,id=GetID()
function s.initial_effect(c)
  -- 【グロウ】 라이프 클로스가 0장
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetCode(EFFECT_GROW_PROC)
  e0:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()==0 end
  end)
  c:RegisterEffect(e0)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_DOUBLE_CRUSH)
  e1:SetRange(LOCATION_LRIG)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ATTACK)
  -- 두지 않아도 된다(FAQ 1)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil)
    if g:GetCount()==0 or not Duel.SelectYesNo(tp) then return end
    if Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT)>0 then Duel.Up(e:GetHandler()) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetCode(EVENT_ON_PLAY)
  -- 0~3장, 칸이 없으면 내지 못한다(FAQ 3~5)
  e3:SetOperation(function(e,tp)
    for tc in aux.Search(tp,Card.IsSigni,3):Iter() do Duel.PutOnField(tc,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e3)
end
