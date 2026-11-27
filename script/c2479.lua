-- WX11-027 羅輝石　ゴルドオラ
-- 【常】：あなたのシグニは対戦相手のライフバーストの効果を受けない。
-- 【自】：あなたのメインフェイズの間、対戦相手のシグニ１体がバニッシュされたとき、あなたのシグニ１体を対象とし、ターン終了時まで、それは【ダブルクラッシュ】を得る。
-- 【出】：あなたのデッキの一番上を公開する。それが＜鉱石＞か＜宝石＞のシグニの場合、それを手札に加える。
-- ライフバースト：あなたのトラッシュから＜鉱石＞のシグニ１枚と＜宝石＞のシグニ１枚を対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x:IsSigni() end)
  e1:SetValue(function(e,sc,sp,burst) return sp~=e:GetHandlerPlayer() and burst end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_BANISHED)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg) return Duel.GetTurnPlayer()==tp and Duel.GetPhase()==PHASE_MAIN and eg:GetFirst():GetOwner()~=tp end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.GrantKeyword(e,tc,EFFECT_DOUBLE_CRUSH) end
  end)  -- [まで]
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetOperation(function(e,tp)
    local x=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,1)):GetFirst()
    if not x then return end
    Duel.RevealCards(x)
    if (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KOUSEKI) or x:IsClass(0,RACE_HOUSEKI)) end)(x) then Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_KOUSEKI)) end,tp,LOCATION_TRASH,0,1,1,nil)
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_HOUSEKI)) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e4:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e4)
end
