-- WX01-004 轟炎　花代・爾改
-- 【常】：あなたのグロウフェイズをスキップする。
-- 【常】：あなたのターンの間、あなたのシグニのパワーを＋5000する。
-- 【起】《赤》《赤》《赤》：このターン、対戦相手はレベル２以下のシグニで【ガード】ができない。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_SKIP_GROW)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(1,0)
  c:RegisterEffect(e1)
  -- [の間] 【常】
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_UPDATE_POWER)
  e2:SetRange(LOCATION_LRIG)
  e2:SetTargetRange(LOCATION_SZONE,0)
  e2:SetTarget(function(e,x) return x:IsSigni() end)
  e2:SetCondition(function(e) return Duel.GetTurnPlayer()==e:GetHandlerPlayer() end)
  e2:SetValue(5000)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetEnaCost("{R}{R}{R}")
  e3:SetOperation(function(e,tp)
    -- [の間] 「このターン」 레벨 1과 2
    for lv=1,2 do
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD)
      e1:SetCode(EFFECT_CANNOT_GUARD)
      e1:SetTargetRange(0,1)
      e1:SetValue(lv)
      e1:SetReset(RESET_PHASE+PHASE_END)
      Duel.RegisterEffect(e1,tp)
    end
  end)
  c:RegisterEffect(e3)
end
