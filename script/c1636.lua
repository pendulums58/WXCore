-- WDK07-Y08 イクエス・ディフェンス
-- ベット―《コインアイコン》
-- ターン終了時まで、対象の対戦相手のシグニ１体は能力を失い、対象の対戦相手のシグニ１体は「【常】：アタックできない。」を得る。あなたがベットしていた場合、追加でターン終了時まで、対象の対戦相手のセンタールリグ１体は「【常】：アタックできない。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local lose,stop,lrig  -- 능력을 잃을 시그니, 어택할 수 없을 시그니(같아도 된다. FAQ 2)·루리그
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    lose=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    stop=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    lrig=Duel.IsBet() and Duel.SelectTarget(tp,nil,tp,0,LOCATION_LRIG,1,1,nil):GetFirst() or nil
  end)
  e1:SetOperation(function(e,tp)
    -- [まで] ターン終了時まで. 능력을 잃은 다음 「アタックできない」를 얻는다(FAQ 3)
    if lose and lose:IsRelateToEffect(e) then
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_LOSE_ABILITY)
      e1:SetReset(RESET_PHASE+PHASE_END)
      lose:RegisterEffect(e1)
    end
    if stop and stop:IsRelateToEffect(e) then aux.GrantKeyword(e,stop,EFFECT_CANNOT_ATTACK) end
    if lrig and lrig:IsRelateToEffect(e) then aux.GrantKeyword(e,lrig,EFFECT_CANNOT_ATTACK) end
  end)
  c:RegisterEffect(e1)
end
