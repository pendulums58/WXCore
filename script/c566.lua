-- WX15-041 三日の天下　アケチ
-- 【ライズ】あなたのレベル２以下の赤のシグニ１体の上に置く
-- 【自】：このシグニがアタックしたとき、対戦相手のパワー7000以下のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②対戦相手のパワー5000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddRise(c,function(x) return x:IsSigni() and x:IsColor(COLOR_RED) and x:GetLevel()<=2 end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(aux.BanishPowerTarget(7000))
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e2:SetOperation(function(e,tp)
    if e:GetLabel()==0 then Duel.Draw(tp,1) return end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=5000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
end
