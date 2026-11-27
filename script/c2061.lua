-- WX04-093 惰眠
-- あなたのデッキの上からシグニがめくれるまで公開する。その後、公開されたシグニを場に出し、残りをトラッシュに置く。その後、この効果を２回繰り返す。（場に出すことのできないシグニはトラッシュに置かれる。【出】能力はこのスペルを処理したあとに好きな順番で発動する）
-- ライフバースト：あなたのデッキの上からカードを３枚見る。その中からカード１枚を手札に加え、残りをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 낼 수 없는 시그니는 트래시. 덱이 0장이면 거기서 끝(FAQ 1·2). 【出】은 처리한 뒤에
  e1:SetOperation(function(e,tp)
    for _=1,3 do
      local n,g,hit=0,nil,nil
      repeat
        n=n+1
        g=Duel.GetDecktopGroup(tp,n)
        hit=g:Filter(Card.IsSigni,nil):GetFirst()
      until hit or g:GetCount()<n
      if g:GetCount()==0 then return end
      Duel.RevealCards(g)
      local rest=g:Filter(function(x) return x~=hit end,nil)
      if hit and not Duel.PutOnField(hit,tp) then rest:AddCard(hit) end
      if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
      if not hit then return end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    local _,rest=aux.ExcavateToHand(tp,3,nil,1,1,true)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
end
