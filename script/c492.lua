-- WX04-025 ダーク・マター
-- 各プレイヤーは自分のシグニ１体を対象とし、それをトラッシュに置く。その後、あなたの場にシグニがない場合、あなたのデッキの一番上のカードをライフクロスに加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 턴 플레이어부터 고르고 함께 트래시(FAQ 3). 이 아츠의 효과다(FAQ 2·5)
  e1:SetOperation(function(e,tp)
    local turn=Duel.GetTurnPlayer()
    local g=Group.CreateGroup()
    for _,p in ipairs{turn,1-turn} do
      local x=Duel.SelectTarget(p,Card.IsSigni,p,LOCATION_SZONE,0,1,1,nil):GetFirst()
      if x then g:AddCard(x) end
    end
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    if Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):GetCount()==0 then
      local top=Duel.GetDecktopGroup(tp,1)
      if top:GetCount()>0 then Duel.SendToLife(top) end
    end
  end)
  c:RegisterEffect(e1)
end
