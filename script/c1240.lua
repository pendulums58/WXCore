-- WD13-016 鉄拳　アークトレット
-- 【出】《白》：あなたのデッキから＜天使＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- ライフバースト：あなたのデッキから＜天使＞か＜アーム＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{W}")
  e1:SetOperation(function(e,tp) aux.SearchToHand(tp,aux.ClassFilter(0,RACE_TENSHI),1) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI) or x:IsClass(0,RACE_ARM)) end,1)
  end)
  c:RegisterEffect(e2)
end
