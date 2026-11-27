-- WX09-Re07 巨弓　ヤエキリ
-- 【常】：あなたの場に＜アーム＞か＜ウェポン＞のシグニが合計３体あるかぎり、このシグニの基本パワーは10000になり、このシグニは「【自】：対戦相手の効果によってこのシグニが場を離れたとき、あなたのデッキからレベル３以下の＜アーム＞か＜ウェポン＞のシグニ１枚を探して場に出し、デッキをシャッフルする。」を得る。
-- ライフバースト：あなたのデッキから＜アーム＞か＜ウェポン＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Ability(id,0))
  g:SetCode(EVENT_LEAVE_FIELD)
  g:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return r&REASON_EFFECT~=0 and rp~=tp end)
  g:SetOperation(function(e,tp)
    local x=aux.Search(tp,function(c) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_ARM) or x:IsClass(0,RACE_WEAPON)) end)(c) and c:GetLevel()<=3 end,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
    aux.ShuffleDeck(tp)
  end)
  local three=function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_ARM) or x:IsClass(0,RACE_WEAPON)) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>=3 end
  -- [の間] 【常】
  aux.BasePower(c,10000,three)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SIGNI,0)
  e1:SetTarget(function(e,x) return x==e:GetHandler() and three(e) end)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_ARM) or x:IsClass(0,RACE_WEAPON)) end,1)
  end)
  c:RegisterEffect(e2)
end
