-- WX20-059 羅石　ニジメノウ
-- 【出】《赤》：あなたのトラッシュから赤のスペル１枚を対象とし、あなたの場にカード名に《イリスアゲート》を含むシグニがある場合、それを手札に加える。
-- 【出】：あなたの手札からコストの合計が１以下の赤のスペル１枚をコストを支払わずに使用してもよい。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{R}")
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_SPELL) and x:IsColor(COLOR_RED) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if Duel.GetMatchingGroup(function(x) return aux.NameHas(x,"イリスアゲート") end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then Duel.SendToHand(tc) end end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(c) return c:IsType(TYPE_SPELL) and c:IsColor(COLOR_RED) and c:GetCostTotal()<=1 end,tp,LOCATION_HAND,0,nil),0,1):GetFirst()
    if x then Duel.UseFree(x,tp) end
  end)
  c:RegisterEffect(e2)
end
