-- WD19-006 フェイタル・パニッシュ
-- ベット―《コインアイコン》《コインアイコン》
-- ターン終了時まで、対戦相手のすべてのシグニのパワーを－7000する。あなたがベットしていた場合、代わりに－12000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(2)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
function s.op(e,tp)
  local v=Duel.IsBet() and -12000 or -7000
  for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do
    aux.AddPower(e,tc,v)  -- [まで] ターン終了時まで. 처리할 때 장에 있는 시그니만
  end
end
