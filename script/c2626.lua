-- WX13-055 千夜の四夜　ソロモン
-- 【出】：あなたのトラッシュから＜悪魔＞のシグニを１枚まで対象とし、あなたの手札が０枚の場合、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_AKUMA)) end,tp,LOCATION_TRASH,0,0,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()==0 then Duel.SendToHand(tc) end end
  end)
  c:RegisterEffect(e1)
end
