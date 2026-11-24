-- WDK03-011 幻怪　ピーター
-- 【自】《ターン１回》：あなたがアーツを使用したとき、ターン終了時まで、あなたのすべての＜怪異＞のシグニは【ランサー】を得る。
-- ライフバースト：対戦相手のパワー10000以上のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
s.kaii=aux.ClassFilter(0,RACE_KAII)  -- ＜怪異＞のシグニ
function s.initial_effect(c)
  -- [まで] 처리할 때 장에 있는 ＜怪異＞만
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_USE_CARD)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep) return ep==tp and eg:GetFirst():IsType(TYPE_ARTS) end)
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetMatchingGroup(s.kaii,tp,LOCATION_SZONE,0,nil):Iter() do
      aux.GrantKeyword(e,tc,EFFECT_LANCER)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=10000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(aux.BanishOp)
  c:RegisterEffect(e2)
end
