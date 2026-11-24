-- WD10-001 勇猛果敢　タマヨリヒメ之肆
-- 【常】：あなたのターンの間、あなたのクロス状態のシグニのパワーを＋5000する。
-- 【自】：あなたのシグニが《ヘブン》したとき、カードを１枚引いてもよい。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetCondition(function(e) return Duel.GetTurnPlayer()==e:GetHandlerPlayer() end)
  e1:SetTarget(function(e,x) return x:IsCross() end)
  e1:SetValue(5000)
  c:RegisterEffect(e1)
  -- 어택 선언으로 다운된 것만 《ヘブン》(FAQ 3)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_HEAVEN)
  e2:SetRange(LOCATION_LRIG)
  e2:SetCondition(function(e,tp,eg,ep) return ep==tp end)
  e2:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e2)
end
