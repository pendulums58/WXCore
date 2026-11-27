-- WX17-022 整理整頓
-- あなたか対戦相手のトラッシュにあるすべてのカードをデッキに加え、そのプレイヤーはデッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    -- 예 = 자신의 트래시, 아니오 = 상대의 트래시
    local p=Duel.SelectYesNo(tp) and tp or 1-tp
    Duel.SendToDeckShuffle(Duel.GetMatchingGroup(nil,p,LOCATION_TRASH,0,nil),p)
  end)
  c:RegisterEffect(e1)
end
