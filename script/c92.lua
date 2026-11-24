-- WD15-010 一覇二鳥
-- ターン終了時まで、あなたのセンタールリグは【ダブルクラッシュ】を得る。このターン、対戦相手はレベル１のシグニで【ガード】ができない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if lc then
      -- [まで] ターン終了時まで
      aux.GrantKeyword(e,lc,EFFECT_DOUBLE_CRUSH)
    end
    -- [の間] 「このターン」
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_GUARD)
    e2:SetTargetRange(0,1)
    e2:SetValue(1)
    e2:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e2,tp)
  end)
  c:RegisterEffect(e1)
end
