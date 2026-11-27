-- WX21-052 嫉妬の炎刃　≡ヘラ≡
-- 【常】：あなたの＜天使＞のシグニは「【自】：対戦相手のターン終了時、対戦相手のパワー5000以下のシグニを２体まで対象とし、このシグニを場からトラッシュに置いてもよい。そうした場合、それらをバニッシュする。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 ＜天使＞가 얻는다
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  g:SetCode(EVENT_TURN_END)
  g:SetRange(LOCATION_SZONE)
  g:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  g:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if not (h:IsLocation(LOCATION_SZONE) and Duel.SelectYesNo(tp)) or Duel.SendToTrash(h,REASON_EFFECT)==0 then return end
    local g=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=5000 end,tp,0,LOCATION_SZONE,0,2,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_FIELD)
  e9:SetDescription(aux.Ability(id,0))
  e9:SetCode(EFFECT_GRANT)
  e9:SetRange(LOCATION_SZONE)
  e9:SetTargetRange(LOCATION_SZONE,0)
  e9:SetTarget(function(e,x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end)(x) end)
  e9:SetLabelObject(g)
  c:RegisterEffect(e9)
end
