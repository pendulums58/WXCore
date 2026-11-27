-- WX11-012 ビザント・ディフェンス
-- 対戦相手のシグニ１体を対象とし、ターン終了時まで、それは「【常】：あなたが《無》《無》《無》を支払わないかぎりアタックできない。」を得る。あなたのセンタールリグが＜タマ＞の場合、代わりにターン終了時まで、それは「【常】：あなたが《無》《無》《無》《無》を支払わないかぎりアタックできない。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    local n=(function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_TAMA) end)() and 4 or 3
    -- 「…を支払わないかぎりアタックできない」(근사: 어택할 때 낼지 묻고 안 내면 그 어택을 무효)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_ATTACK)
    e1:SetCondition(function(e2,tp2,eg) return eg:GetFirst()==tc end)
    e1:SetOperation(function()
      local p=1-tp
      local cost=string.rep("{C}",n)
      if Duel.CanPayEna(p,cost) and Duel.SelectYesNo(p) then
        Duel.SendToTrash(Duel.SelectEnaCost(p,cost),REASON_COST)
      else
        Duel.NegateAttack()
      end
    end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
