-- WX04-084 ＡＴＴＲＡＣＴＩＯＮ
-- あなたのデッキからコストの合計が１のスペル１枚とコストの合計が２のスペル１枚とコストの合計が３のスペル１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 적힌 코스트의 합계. 덜 찾아도 된다(FAQ 1·2)
  e1:SetOperation(function(e,tp)
    local f=function(x) return x:IsType(TYPE_SPELL) and x:GetCostTotal()>=1 and x:GetCostTotal()<=3 end
    Duel.SetSelectCheck(function(sg)
      local seen={}
      for x in sg:Iter() do
        if seen[x:GetCostTotal()] then return false end
        seen[x:GetCostTotal()]=true
      end
      return true
    end)
    local g=aux.Search(tp,f,3)
    if g:GetCount()>0 then
      Duel.RevealCards(g)
      Duel.SendToHand(g)
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
end
