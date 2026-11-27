-- WX08-081 デッド・メイク
-- 対戦相手は自分のシグニ１体につき自分のデッキの上からカード１枚を、それらの【チャーム】にする。
-- （【チャーム】は裏向きでシグニに付き、１体に１枚までしか付けられない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    for x in Duel.GetMatchingGroup(Card.IsSigni,1-tp,LOCATION_SZONE,0,nil):Iter() do
      local top=Duel.GetDecktopGroup(1-tp,1):GetFirst()
      if top and not x:GetCharm() then Duel.Charm(top,x) end
    end
  end)
  c:RegisterEffect(e1)
end
