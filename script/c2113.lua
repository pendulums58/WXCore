-- WX05-052 ゲット・アルマンダル
-- 以下の２つから２つまで選ぶ。
-- ①あなたのデッキからレベル２以下の白のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- ②あなたのセンタールリグがレベル４以上で白の場合、あなたのデッキからシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m&1~=0 then aux.SearchToHand(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_WHITE) and x:IsLevelBetween(0,2) end,1) end
    if m&2~=0 and (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:GetLevel()>=4 and lc:IsColor(COLOR_WHITE) end)() then aux.SearchToHand(tp,Card.IsSigni,1) end
  end)
  c:RegisterEffect(e1)
end
