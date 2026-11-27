-- WX22-043 コードイート　クギニ
-- 【出】：あなたの手札から《アクセアイコン》を持つシグニを２枚までエナゾーンに置く。この方法でカードを２枚エナゾーンに置いた場合、カードを１枚引く。
-- 【起】《緑×0》：あなたのシグニ１体を対象とし、このカードをエナゾーンからそれの【アクセ】にする。
-- 【常】：これにアクセされている＜調理＞のシグニはすべての色を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:HasAcceIcon() end,tp,LOCATION_HAND,0,nil),0,2)
    if g:GetCount()==0 then return end
    Duel.SendToEna(g)
    if g:GetCount()==2 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
  aux.AddAcce(c,aux.Ability(id,1))
  -- [の間] 【常】 붙은 ＜調理＞는 모든 색
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EFFECT_ADD_COLOR)
  e2:SetRange(LOCATION_ACCE)
  e2:SetTargetRange(LOCATION_SZONE,0)
  e2:SetTarget(function(e,x) return x==e:GetHandler():GetAcceHost() and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_CHOURI)) end)(x) end)
  e2:SetValue(COLOR_WHITE|COLOR_RED|COLOR_BLUE|COLOR_GREEN|COLOR_BLACK)
  c:RegisterEffect(e2)
end
