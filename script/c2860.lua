-- WX16-042 ＵＮＬＵＣＫＹ
-- 手札からシグニを１枚捨てる。その後、捨てたシグニと同じレベルの対戦相手のシグニ１体を対象とし、それをバニッシュする。あなたはこの効果をあと２回まで繰り返してもよい。（合計で最大３回まで行える）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    for i=1,3 do
      local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_HAND,0,nil)
      if g:GetCount()==0 or (i>1 and not Duel.SelectYesNo(tp)) then break end
      local x=Duel.SelectCards(tp,g,1,1):GetFirst()
      Duel.SendToTrash(x,REASON_EFFECT+REASON_DISCARD)
      local lv=x:GetLevel()
      local tc=Duel.SelectTarget(tp,function(c) return c:IsSigni() and c:GetLevel()==lv end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.Banish(tc) end
    end
  end)
  c:RegisterEffect(e1)
end
