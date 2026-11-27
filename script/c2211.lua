-- WX07-042 幻獣　ラクダ
-- 【自】：あなたのシグニが【ランサー】によって対戦相手のライフクロスをクラッシュしたとき、カードを１枚引く。
-- 【起】《ターン１回》ターン終了時まで、このシグニのパワーを5000減らす：ターン終了時まで、このシグニは【ランサー】を得る。
local s,id=GetID()
function s.initial_effect(c)
  -- 배틀 없이 크러시한 것은 아니다(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_CRUSHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) return ep~=tp and r&REASON_LANCER~=0 end)
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  -- 파워를 줄이는 것은 코스트(FAQ 2)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    aux.AddPower(e,e:GetHandler(),-5000)
  end)
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then aux.GrantKeyword(e,h,EFFECT_LANCER) end  -- [まで]
  end)
  c:RegisterEffect(e2)
end
