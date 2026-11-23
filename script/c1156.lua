-- WD07-007 ブラック・クライシス
-- あなたのデッキの上からカードを４枚トラッシュに置く。その後、その中に黒のカードがある場合、あなたのトラッシュから黒のシグニ１枚を対象とし、
-- それを手札に加える。その中に白のカードがある場合、あなたのデッキから白のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
function s.op(e,tp)
  local g=Duel.GetDecktopGroup(tp,4)
  if g:GetCount()==0 then return end
  Duel.SendToTrash(g,REASON_EFFECT)
  local black,white=false,false
  for x in g:Iter() do
    if x:IsLocation(LOCATION_TRASH) then
      black=black or x:IsColor(COLOR_BLACK)
      white=white or x:IsColor(COLOR_WHITE)
    end
  end
  -- 방금 놓은 카드도 대상이 된다
  if black then
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if tc then Duel.SendToHand(tc) end
  end
  if white then
    aux.SearchToHand(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_WHITE) end,1)
  end
end
