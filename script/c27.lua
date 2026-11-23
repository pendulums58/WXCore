-- WD08-006 アンシエント・サプライズ
-- 以下の３つから１つを選ぶ。
-- ①各プレイヤーは自分のデッキの上からカードを７枚トラッシュに置く。
-- ②あなたのトラッシュからレベル３以下の＜古代兵器＞のシグニ１枚を対象とし、それを場に出す。
-- ③あなたのトラッシュにカードが１０枚以上ある場合、ターン終了時まで、対戦相手のすべてのシグニのパワーを－5000する。
--   ２０枚以上ある場合、代わりにターン終了時まで、対戦相手のすべてのシグニのパワーを－8000する。
local s,id=GetID()
function s.initial_effect(c)
  -- 모드는 사용 선언 때(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2)))
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==1 then Duel.SelectTarget(tp,s.filter,tp,LOCATION_TRASH,0,1,1,nil) end
  end)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
function s.filter(x) return x:IsSigni() and x:IsClass(0,RACE_KODAIHEIKI) and x:GetLevel()<=3 end
function s.op(e,tp)
  local m=e:GetLabel()
  if m==0 then
    local g=Group.CreateGroup()
    for _,p in ipairs({tp,1-tp}) do
      for x in Duel.GetDecktopGroup(p,7):Iter() do g:AddCard(x) end
    end
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  elseif m==1 then
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
  else
    local n=Duel.GetMatchingGroup(nil,tp,LOCATION_TRASH,0,nil):GetCount()
    if n<10 then return end
    -- [まで] 처리할 때 장에 있는 시그니만(FAQ 2)
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SIGNI,nil):Iter() do
      aux.AddPower(e,tc,n>=20 and -8000 or -5000)
    end
  end
end
