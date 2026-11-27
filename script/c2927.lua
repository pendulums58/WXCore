-- WX17-040 連滅の凱歌
-- 以下の３つから３つまで選ぶ。
-- ①対戦相手の手札があなたより多い場合、カードを１枚引く。
-- ②対戦相手のエナゾーンにあるカードがあなたより多い場合、あなたのデッキの一番上のカードをエナゾーンに置く。
-- ③対戦相手のシグニ１体を対象とし、対戦相手のライフクロスの枚数があなたより多い場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,3,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    local cnt=function(p,loc) return Duel.GetMatchingGroup(nil,p,loc,0,nil):GetCount() end
    if m&1~=0 and cnt(1-tp,LOCATION_HAND)>cnt(tp,LOCATION_HAND) then Duel.Draw(tp,1) end
    if m&2~=0 and cnt(1-tp,LOCATION_ENA)>cnt(tp,LOCATION_ENA) then Duel.EnaCharge(tp,1) end
    if m&4~=0 then
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc and cnt(1-tp,LOCATION_LIFE)>cnt(tp,LOCATION_LIFE) then Duel.Banish(tc) end
    end
  end)
  c:RegisterEffect(e1)
end
