-- WX21-022 幻怪妖姫　タマモゼン
-- 【レイヤー】あなたの＜怪異＞のシグニは《レイヤーアイコン》の能力を得る
-- 《レイヤーアイコン》【常】：対戦相手のアタックフェイズの間、このシグニは【シャドウ】を得る。
-- 【常】：対戦相手は自分のルリグアタックステップをスキップする。
-- ライフバースト：あなたのトラッシュから＜怪異＞のシグニ１枚を手札に加える。その後、この方法で手札に加えたシグニのレベル以下の対戦相手のシグニ１体を対象とし、それを手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【レイヤー】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_SHADOW)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KAII)) end)(x) end)
  e1:SetCondition(function(e) return Duel.GetTurnPlayer()~=e:GetHandlerPlayer() and Duel.GetPhase()==PHASE_ATTACK end)
  c:RegisterEffect(e1)
  -- [の間] 【常】
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_SKIP_LRIG_ATTACK)
  e2:SetRange(LOCATION_SZONE)
  e2:SetTargetRange(0,1)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KAII)) end,tp,LOCATION_TRASH,0,nil),0,1):GetFirst()
    if not x or Duel.SendToHand(x)==0 then return end
    local lv=x:GetLevel()
    local tc=Duel.SelectTarget(tp,function(c) return c:IsSigni() and c:GetLevel()<=lv end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e3)
end
