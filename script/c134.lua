-- WD09-006 ロマネ・ディフェンス
-- 対戦相手のシグニ１体を対象とし、ターン終了時まで、それは「【常】：アタックできない。」を得る。手札を１枚捨てる。
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
    if tc and tc:IsRelateToEffect(e) then
      -- [まで] ターン終了時まで. 상태를 바꾸는 효과라 「アーツの効果を受けない」에 막힌다(FAQ 2)
      aux.GrantKeyword(e,tc,EFFECT_CANNOT_ATTACK)
    end
    -- 패가 0장이면 버리기는 무시(FAQ 1)
    aux.Discard(tp,1)
  end)
  c:RegisterEffect(e1)
end
