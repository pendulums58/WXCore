-- WD13-010 バインド・ウェポンズ
-- 以下の２つから１つを選ぶ。
-- ①このターン、あなたのライフクロスはダメージ以外によってはクラッシュされない。
-- ②このターン、対戦相手のセンタールリグとシグニはそれぞれ一度しかアタックできない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e1:SetOperation(function(e,tp)
    -- [の間] 「このターン」
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetReset(RESET_PHASE+PHASE_END)
    if e:GetLabel()==0 then
      e1:SetCode(EFFECT_CANNOT_CRUSH)
      e1:SetTargetRange(1,0)
      e1:SetValue(CRUSH_NON_DAMAGE)
    else
      e1:SetCode(EFFECT_ATTACK_ONCE)
      e1:SetTargetRange(0,LOCATION_LRIG+LOCATION_SZONE)
    end
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
