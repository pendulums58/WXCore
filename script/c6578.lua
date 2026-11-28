-- WXK05-036 紅蓮の使い魔　ダークアリス
-- 【常】：あなたの場に《紅蓮の使い魔　アリス》があるかぎり、このシグニのパワーは＋3000され、このシグニは【ダブルクラッシュ】を得る。
-- 【自】：このシグニが血晶武装状態になったとき、あなたのデッキから《紅蓮の使い魔　アリス》１枚を探して場に出し、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(function(x) return x:IsCardName(6579) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0 end)
  e1:SetValue(3000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e2:SetDescription(aux.Ability(id,0))
  e2:SetCode(EFFECT_DOUBLE_CRUSH)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e) return Duel.GetMatchingGroup(function(x) return x:IsCardName(6579) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0 end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,1))
  e3:SetCode(EVENT_BLOOD_ARMED)
  e3:SetCondition(function(e,tp,eg) return eg:IsContains(e:GetHandler()) end)
  e3:SetOperation(function(e,tp,eg)
    local x=aux.Search(tp,function(y) return y:IsCardName(6579) end,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e3)
end
