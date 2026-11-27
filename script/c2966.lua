-- WX18-005 金剛不壊
-- ベット―《コインアイコン》《コインアイコン》
-- 以下の４つから２つまで選ぶ。あなたがベットしていた場合、代わりに３つまで選ぶ。
-- ①パワー15000以上のすべてのシグニをバニッシュする。
-- ②対戦相手のパワー12000以上のシグニ１体を対象とし、それをバニッシュする。
-- ③あなたのデッキの上からカードを３枚エナゾーンに置く。
-- ④あなたのデッキの一番上のカードをライフクロスに加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(2)
  e1:SetDeclare(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,Duel.IsBet() and 3 or 2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m&1~=0 then local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetPower()>=15000 end,tp,LOCATION_SZONE,LOCATION_SZONE,nil) if g:GetCount()>0 then Duel.Banish(g) end end
    if m&2~=0 then local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=12000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() if tc then Duel.Banish(tc) end end
    if m&4~=0 then Duel.EnaCharge(tp,3) end
    if m&8~=0 then local x=Duel.GetDecktopGroup(tp,1):GetFirst() if x then Duel.SendToLife(x) end end
  end)
  c:RegisterEffect(e1)
end
