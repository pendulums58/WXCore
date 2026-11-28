-- WXK10-035 コードＶＬ　リゼ・ヘルエスタ
-- 【常】：あなたの＜電機＞のシグニは対戦相手のレベル１以下のシグニの効果を受けない。あなたの登録者数が５０万人を達成しているかぎり、代わりにあなたの＜電機＞のシグニは対戦相手のレベル２以下のシグニの効果を受けない。
-- 【自】：このシグニがアタックしたとき、あなたの場に《コードＶＬ　アンジュ・カトリーナ》がある場合、【エナチャージ１】をする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end)(x) end)
  e1:SetValue(function(e,sc,sp) local lv=Duel.GetSubscribers(e:GetHandlerPlayer())>=50 and 2 or 1 return sp~=e:GetHandlerPlayer() and sc:IsSigni() and sc:GetLevel()<=lv end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetOperation(function(e,tp,eg)
    if Duel.GetMatchingGroup(function(x) return x:IsCardName(7010) end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e2)
end
