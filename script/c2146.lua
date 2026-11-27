-- WX06-025 ラッキー・スリー
-- あなたのデッキからそれぞれレベルの異なる無色ではないシグニ３枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 레벨이 다른 3장이 없으면 하나도(FAQ 2)
  e1:SetOperation(function(e,tp)
    Duel.ConfirmCards(tp,Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil))
    Duel.SetSelectCheck(function(g)
      if g:GetCount()==0 then return true end
      if g:GetCount()~=3 then return false end
      local seen={}
      for x in g:Iter() do
        if seen[x:GetLevel()] then return false end
        seen[x:GetLevel()]=true
      end
      return true
    end)
    local g=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetColor()~=0 end,tp,LOCATION_MDECK,0,nil),0,3)
    if g:GetCount()>0 then
      Duel.RevealCards(g)
      Duel.SendToHand(g)
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
end
