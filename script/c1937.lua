-- WX02-050 ソード・アビリティ
-- あなたのデッキから＜アーム＞のシグニ１枚と ＜天使＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    -- ＜アーム＞ 1장과 ＜天使＞ 1장. 한쪽만 찾아도 된다. 둘 다인 카드는 어느 한쪽으로 센다
    local fa,fb=function(x) return x:IsSigni() and (x:IsClass(0,RACE_ARM)) end,function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end
    Duel.SetSelectCheck(function(sg)
      if sg:GetCount()<2 then return true end
      local l={}
      for x in sg:Iter() do l[#l+1]=x end
      return (fa(l[1]) and fb(l[2])) or (fa(l[2]) and fb(l[1]))
    end)
    local g=aux.Search(tp,function(x) return fa(x) or fb(x) end,2)
    if g:GetCount()>0 then
      Duel.RevealCards(g)
      Duel.SendToHand(g)
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
end
