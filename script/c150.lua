-- PR-258 紆余曲折（劇場版selector来場特典）
-- ターン終了時まで、あなたのセンタールリグは
-- 「【起】エクシード１：対戦相手のパワー12000以上のシグニ１体を対象とし、それをバニッシュする。」
-- 「【起】エクシード１：あなたのエナゾーンからカード１枚を対象とし、それを手札に加える。」
-- 「【起】エクシード１：あなたのデッキの一番上のカードをエナゾーンに置く。」
-- を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if not lc then return end
    do
      local g=Effect.CreateEffect(e:GetHandler())
      g:SetType(EFFECT_TYPE_IGNITION)
      g:SetDescription(aux.Stringid(id,0))
      g:SetRange(LOCATION_LRIG)
      g:SetExceedCost(1)
      g:SetTarget(function(e2,tp2,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return true end
        Duel.SelectTarget(tp2,function(x) return x:IsSigni() and x:GetPower()>=12000 end,tp2,0,LOCATION_SZONE,1,1,nil)
      end)
      g:SetOperation(function(e2,tp2)
        local tc=Duel.GetFirstTarget()
        if tc and tc:IsRelateToEffect(e2) then Duel.Banish(tc) end
      end)
      g:SetReset(RESET_PHASE+PHASE_END)
      lc:GrantEffect(g)
    end
    do
      local g=Effect.CreateEffect(e:GetHandler())
      g:SetType(EFFECT_TYPE_IGNITION)
      g:SetDescription(aux.Stringid(id,1))
      g:SetRange(LOCATION_LRIG)
      g:SetExceedCost(1)
      g:SetTarget(function(e2,tp2,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return true end
        Duel.SelectTarget(tp2,nil,tp2,LOCATION_ENA,0,1,1,nil)
      end)
      g:SetOperation(function(e2,tp2)
        local tc=Duel.GetFirstTarget()
        if tc and tc:IsRelateToEffect(e2) then Duel.SendToHand(tc) end
      end)
      g:SetReset(RESET_PHASE+PHASE_END)
      lc:GrantEffect(g)
    end
    do
      local g=Effect.CreateEffect(e:GetHandler())
      g:SetType(EFFECT_TYPE_IGNITION)
      g:SetDescription(aux.Stringid(id,2))
      g:SetRange(LOCATION_LRIG)
      g:SetExceedCost(1)
      g:SetOperation(function(e2,tp2)
        Duel.EnaCharge(tp2,1)
      end)
      g:SetReset(RESET_PHASE+PHASE_END)
      lc:GrantEffect(g)
    end
  end)
  c:RegisterEffect(e1)
end
