-- WX16-065 ＦＵＮＮＹ
-- カードを１枚引く。対戦相手は手札を１枚捨てる。
-- 《トラップアイコン》：対戦相手のターンの場合、カードを１枚引き、対戦相手は手札を１枚捨てる。
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②対戦相手は手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
    aux.Discard(1-tp,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_TRAP)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetOperation(function(e,tp)
    if Duel.GetTurnPlayer()~=tp then Duel.Draw(tp,1) aux.Discard(1-tp,1) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e3:SetOperation(function(e,tp)
    if e:GetLabel()==0 then Duel.Draw(tp,1) else aux.Discard(1-tp,1) end
  end)
  c:RegisterEffect(e3)
end
