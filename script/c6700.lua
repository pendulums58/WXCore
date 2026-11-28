-- WXK06-085 幻竜　ブラックドラゴン
-- 【出】：対戦相手のシグニ１体を対象とし、対戦相手の場にシグニが３体ある場合、ターン終了時まで、それのパワーを－2000する。
-- （パワーが０以下のシグニはルールによってバニッシュされる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      if Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):GetCount()==3 then aux.AddPower(e,tc,-2000) end
    end
  end)
  c:RegisterEffect(e1)
end
