-- WX22-025 天空の主神　ゼウシアス
-- 【常】：【マルチエナ】
-- 【常】：【シャドウ】
-- 【常】：このシグニはすべての色を得る。
-- 【自】《ターン１回》：このシグニがアタックしたとき、対戦相手が、対象の自分のシグニ１体を場からトラッシュに置くか、自分の手札を２枚捨てるか、対象の自分のエナゾーンからカード３枚をトラッシュに置かないかぎり、対戦相手にダメージを与える。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 셋. 「すべての色を得る」는 아직(근사 없음)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_MULTI_ENA)
  e1:SetRange(LOCATION_ENA)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_SHADOW)
  e2:SetRange(LOCATION_SZONE)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetCode(EVENT_ATTACK)
  e3:SetCountLimit(1)
  e3:SetOperation(function(e,tp)
    local o=1-tp
    -- 상대: 0 = 시그니 1체 트래시, 1 = 패 2장, 2 = 에나 3장, 3 = 하지 않는다(대미지)
    local m=Duel.SelectOption(o,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))
    if m==0 then local tc=Duel.SelectTarget(o,Card.IsSigni,o,LOCATION_SZONE,0,1,1,nil):GetFirst() if tc and Duel.SendToTrash(tc,REASON_EFFECT)>0 then return end
    elseif m==1 and Duel.GetMatchingGroup(nil,o,LOCATION_HAND,0,nil):GetCount()>=2 then aux.Discard(o,2) return
    elseif m==2 and Duel.GetMatchingGroup(nil,o,LOCATION_ENA,0,nil):GetCount()>=3 then Duel.SendToTrash(Duel.SelectTarget(o,nil,o,LOCATION_ENA,0,3,3,nil),REASON_EFFECT) return end
    Duel.Damage(o)
  end)
  c:RegisterEffect(e3)
end
