-- WX16-021 驚天動地
-- このターン、あなたの＜英知＞のシグニがシグニのない対戦相手のシグニゾーンにアタックする場合、代わりにそのアタックではそのシグニゾーンの正面にあるかのように対戦相手にダメージを与える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 「シグニのないシグニゾーンにアタックする場合…ダメージを与える」는 아직(근사 없음)
  e1:SetOperation(function(e,tp)
    
  end)
  c:RegisterEffect(e1)
end
