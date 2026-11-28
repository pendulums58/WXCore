-- WXK04-053 ＭＯＵＮＴＡＩＮ　ＩＣＥ
-- あなたの＜調理＞のシグニ１体を対象とし、それは場にあるかぎり、「【常】：このシグニには好きな枚数の【アクセ】を付けることができる。」を得る。（ターンが終了しても能力を得たままである）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  -- 「好きな枚数の【アクセ】を付けることができる」는 아직(【アクセ】는 1장까지)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    
  end)
  c:RegisterEffect(e1)
end
