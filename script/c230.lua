-- PR-365 セレクター（「selector」Best -Ever After-初回生産限定特典）
-- あなたのデッキから、限定条件にあなたのセンタールリグのルリグタイプを持つカード１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 한정 조건이 없는 카드는 안 된다(FAQ 2)
  e1:SetOperation(function(e,tp)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    local types=lc and lc:GetLrigTypes() or {}
    local g=aux.Search(tp,function(x)
      for _,t in ipairs(types) do if x:IsLimitCond(t) then return true end end
      return false
    end,1)
    if g:GetCount()>0 then
      Duel.RevealCards(g)
      Duel.SendToHand(g)
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
end
