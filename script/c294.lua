-- PR-467 幻怪　ベイＢジャック（コロコロアニキ2018年秋号 付録）
-- 【常】：このシグニはダウン状態で場に出る。
-- 【常】：【ダブルクラッシュ】
-- 【常】：あなたがエナコストを支払う際、このシグニをダウンすることで《緑》か《無》１つを支払える。
-- 【常】：２０１９年３月１日以降、このシグニは場に出せない。（場にある場合、トラッシュに置く）
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  -- 【常】 2019년 3월 1일 이후로는 장에 낼 수 없다(장에 있으면 트래시)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,3))
  e1:SetCode(EFFECT_CANNOT_PLAY)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetCode(EVENT_ON_PLAY)
  -- 위 【常】의 「場にある場合、トラッシュに置く」
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then Duel.SendToTrash(h,REASON_RULE) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e3:SetDescription(aux.Ability(id,1))
  e3:SetCode(EFFECT_DOUBLE_CRUSH)
  e3:SetRange(LOCATION_SZONE)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e4)
end
