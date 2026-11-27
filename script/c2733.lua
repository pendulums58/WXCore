-- WX14-073 コードアート　†Ｈ・Ｍ・Ｆ†
-- 【常】：あなたのトラッシュにスペルがあるかぎり、このシグニの基本パワーは8000になる。
-- 【出】：対戦相手のシグニ１体を対象とし、あなたのトラッシュにスペルが３枚以上ある場合、ターン終了時まで、それのパワーを－3000する。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,8000,function(e) return Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_SPELL) end,e:GetHandlerPlayer(),LOCATION_TRASH,0,nil):GetCount()>0 end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_SPELL) end,tp,LOCATION_TRASH,0,nil):GetCount()>=3 then aux.AddPower(e,tc,-3000) end end
  end)  -- [まで]
  c:RegisterEffect(e1)
end
