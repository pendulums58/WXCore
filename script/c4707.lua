-- WXDi-D01-014 ツヴァイ＝スローロリス
-- 【常】：あなたのエナゾーンにあるシグニが持つクラスが合計３種類以上あるかぎり、このシグニのパワーは＋５０００される。
-- 【起】《ターン１回》《緑》《緑》《無》：あなたの他のパワー１５０００以上のシグニ１体を対象とし、ターン終了時まで、それは【ランサー】を得る。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(s.con)
  e1:SetValue(5000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetEnaCost("{G}{G}{C}")
  e2:SetTarget(s.tg)
  e2:SetOperation(s.op)
  c:RegisterEffect(e2)
end
function s.con(e)
  local tp=e:GetHandlerPlayer()
  return aux.ClassCount(Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_ENA,0,nil))>=3
end
function s.filter(c) return c:IsSigni() and c:GetPower()>=15000 end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_SZONE,0,1,e:GetHandler()) end
  Duel.SelectTarget(tp,s.filter,tp,LOCATION_SZONE,0,1,1,e:GetHandler())
end
-- 파워는 대상으로 고를 때만 본다. 뒤에 15000 아래로 내려가도 【ランサー】는 남는다(FAQ 1)
function s.op(e,tp)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then
    -- [まで] ターン終了時まで
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_LANCER)
    e1:SetReset(RESET_PHASE+PHASE_END)
    tc:GrantEffect(e1)
  end
end
