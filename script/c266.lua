-- PR-422 ３－遊　§タカラトミーたそ§（2017年度タカラトミーモールキャンペーン）
-- 【自】：パワー０以下のこのシグニがバニッシュされたとき、あなたはゲームに敗北する。
-- 【自】：あなたのターン終了時、このシグニのパワーが10000以上の場合、このシグニを場からトラッシュに置き、カードを３枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  -- 파워 0 이하의 룰 처리 바니시(「バニッシュされない」면 트리거하지 않는다. FAQ 1·2)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) return r&REASON_RULE~=0 end)
  e1:SetOperation(function(e,tp)
    Duel.Lose(tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_TURN_END)
  e2:SetRange(LOCATION_SZONE)
  -- 「ターン終了時まで」가 풀리기 전(FAQ 3)
  e2:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:GetPower()>=10000 and Duel.SendToTrash(h,REASON_EFFECT)>0 then Duel.Draw(tp,3) end
  end)
  c:RegisterEffect(e2)
end
