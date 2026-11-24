-- WD15-023 振子の乱舞
-- このターン、あなたの＜龍獣＞のシグニが対戦相手のシグニ１体をバニッシュしたとき、その＜龍獣＞のシグニより低いレベルを持つ対戦相手のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    -- [の間] 「このターン」. 이 효과는 스펠의 효과라 이것으로 바니시해도 다시 트리거하지 않는다(FAQ 3)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetDescription(aux.Ability(id,0))
    e1:SetCode(EVENT_BANISHED)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetCondition(function(e,tp,eg,ep)
      local x=Duel.GetBanisher()
      return ep~=tp and x and x:IsSigni() and x:IsClass(0,RACE_RYUJU) and x:GetControler()==tp
    end)
    e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
      if chk==0 then return true end
      local lv=Duel.GetBanisher():GetLevel()
      Duel.SelectTarget(tp,function(c) return c:IsSigni() and c:GetLevel()<lv end,tp,0,LOCATION_SZONE,1,1,nil)
    end)
    e1:SetOperation(function(e,tp)
      local tc=Duel.GetFirstTarget()
      if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
    end)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
