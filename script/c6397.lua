-- WXK03-023 聖炎の輪舞
-- このスペルを使用する際、使用コストとして追加であなたのシグニの下からカードを合計４枚までトラッシュに置いてもよい。
-- 手札を１枚捨て、カードを１枚引く。あなたがこのカードを使用する際にシグニの下からカードを２枚以上トラッシュに置いていた場合、追加でカードを１枚引く。４枚トラッシュに置いていた場合、追加で対象の対戦相手のシグニ１体をバニッシュする。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local n=0  -- 코스트로 시그니 아래에서 둔 장수
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    n=0
    local u=Group.CreateGroup()
    for x in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do for y in x:GetUnderGroup():Iter() do u:AddCard(y) end end
    if u:GetCount()==0 then return end
    local g=Duel.SelectCards(tp,u,0,4)
    n=g:GetCount()
    e:SetLabelObject(nil)
    s.picked=g
  end)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if n>0 then Duel.SendToTrash(s.picked,REASON_COST) end
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if n==4 then Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp,eg)
    -- 대상은 손패를 버리기 전에 고른다(FAQ 5)
    aux.Discard(tp,1)
    Duel.Draw(tp,1)
    if n>=2 then Duel.Draw(tp,1) end
    if n==4 then
      local tc=Duel.GetFirstTarget()
      if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
    end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e9)
end
