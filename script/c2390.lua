-- WX10-011 駆馬炎鞭
-- このカードはあなたのセンタールリグがレベル３以上の場合にしか使用できない。
-- このゲームの間、あなたのセンタールリグは【ダブルクラッシュ】を得て、あなたはグロウできない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCondition(function(e,tp) local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:GetLevel()>=3 end)
  e1:SetOperation(function(e,tp)
    -- 「このゲームの間」 센터 루리그는 【ダブルクラッシュ】, 그로우할 수 없다(효과도. FAQ 1)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_DOUBLE_CRUSH)
    e1:SetTargetRange(LOCATION_LRIG,0)
    Duel.RegisterEffect(e1,tp)
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_GROW)
    e2:SetTargetRange(1,0)
    Duel.RegisterEffect(e2,tp)
  end)
  c:RegisterEffect(e1)
end
