-- WX01-038 ゲット・ダンタリアン
-- あなたのデッキから白のシグニ１枚と赤のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 한쪽만 찾아도 된다(FAQ 1)
  e1:SetOperation(function(e,tp)
    local w=function(x) return x:IsSigni() and x:IsColor(COLOR_WHITE) end
    local r=function(x) return x:IsSigni() and x:IsColor(COLOR_RED) end
    -- 백 1장과 적 1장. 둘 다인 카드는 어느 한쪽으로 센다
    Duel.SetSelectCheck(function(sg)
      if sg:GetCount()<2 then return true end
      local l={}
      for x in sg:Iter() do l[#l+1]=x end
      return (w(l[1]) and r(l[2])) or (w(l[2]) and r(l[1]))
    end)
    local g=aux.Search(tp,function(x) return w(x) or r(x) end,2)
    if g:GetCount()>0 then
      Duel.RevealCards(g)
      Duel.SendToHand(g)
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
end
