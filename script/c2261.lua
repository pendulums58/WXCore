-- WX08-015 ハンマー・チャンス
-- このカードはあなたのライフクロスが０枚の場合にしか使用できない。
-- あなたのデッキの上からカードを２枚ライフクロスに加える。このゲームの間、あなたは《ハンマー・チャンス》を使用できない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCondition(function(e,tp) return Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()==0 end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,2)
    if g:GetCount()>0 then Duel.SendToLife(g) end
    -- 「このゲームの間」
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_USE)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(e,x) return x:IsCardName(id) end)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
