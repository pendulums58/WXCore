-- WX12-Re02 ケミカル・フラッシュ
-- あなたのトラッシュからそれぞれ名前の異なる＜原子＞のシグニを好きな数対象とし、それらをデッキの一番下に置く。その後、対戦相手のシグニを、レベルの合計がこの方法でデッキの一番下に置いたシグニの数以下になるように好きな数対象とし、それらをバニッシュする。その後、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local f=function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end
    local g=Duel.GetMatchingGroup(f,tp,LOCATION_TRASH,0,nil)
    Duel.SetSelectCheck(function(sg)
      local seen={}
      for x in sg:Iter() do
        if seen[x:GetCode()] then return false end
        seen[x:GetCode()]=true
      end
      return true
    end)
    local pick=Duel.SelectCards(tp,g,0,g:GetCount())
    local n=0
    if pick:GetCount()>0 then
      Duel.SendToDeckBottom(Duel.SelectOrder(tp,pick),false)
      n=pick:GetCount()
    end
    if n>0 then
      Duel.SetSelectCheck(function(sg)
        local lv=0
        for x in sg:Iter() do lv=lv+x:GetLevel() end
        return lv<=n
      end)
      local t=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,3,nil)
      if t:GetCount()>0 then Duel.Banish(t) end
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
end
