-- WX21-Re02 幻水　スズメダ
-- 【常】：あなたの手札が対戦相手より多いかぎり、このシグニの基本パワーは8000になる。
-- 【出】：あなたの手札が３枚以下の場合、カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,8000,function(e) local p=e:GetHandlerPlayer() return Duel.GetMatchingGroup(nil,p,LOCATION_HAND,0,nil):GetCount()>Duel.GetMatchingGroup(nil,p,0,LOCATION_HAND,nil):GetCount() end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()<=3 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
end
