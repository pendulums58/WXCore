-- PR-423 幻獣　定時ほー＆甲たそ（2017年度タカラトミーモールキャンペーン）
-- 【自】：メインフェイズかアタックフェイズの間、対戦相手が自分の効果でカードを１枚引いたとき、対戦相手にダメージを与える。その後、このシグニをバニッシュする。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_DRAW)
  e1:SetRange(LOCATION_SZONE)
  -- 상대 자신의 효과로 뽑았을 때. 한 장마다(FAQ 1·3). 손에 넣기는 아니다(FAQ 2)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) local ph=Duel.GetPhase() return ep~=tp and rp==ep and r&REASON_EFFECT~=0 and (ph==PHASE_MAIN or ph==PHASE_ATTACK) end)
  e1:SetOperation(function(e,tp)
    Duel.Damage(1-tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then Duel.Banish(h) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
end
