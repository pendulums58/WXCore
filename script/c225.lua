-- WX12-CB01 幻竜　ボルシャック
-- 【常】：あなたのアタックフェイズの間、このシグニのパワーはあなたのトラッシュにある＜龍獣＞のシグニ１枚につき＋1000される。
-- 【常】：このシグニはパワーが12000以上であるかぎり、【ダブルクラッシュ】を得る。
-- 【自】：このシグニがアタックしたとき、対戦相手のパワー10000以下のシグニ１体を対象とし、あなたのトラッシュに＜龍獣＞のシグニが１０枚以上ある場合、それをバニッシュする。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 둘
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetTurnPlayer()==e:GetHandlerPlayer() and Duel.GetPhase()==PHASE_ATTACK end)
  e1:SetValue(function(e) return 1000*Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end,e:GetHandlerPlayer(),LOCATION_TRASH,0,nil):GetCount() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_DOUBLE_CRUSH)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e) return e:GetHandler():GetPower()>=12000 end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ATTACK)
  e3:SetTarget(aux.BanishPowerTarget(10000))
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end,tp,LOCATION_TRASH,0,nil):GetCount()>=10 then Duel.Banish(tc) end end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e4)
end
