-- WX11-051 レベル・ダウン
-- 対象の対戦相手のレベル３以下のシグニ１体をバニッシュし、ターン終了時まで、対象の対戦相手のシグニ１体の基本レベルを１にする。
-- ライフバースト：どちらか１つを選ぶ。①あなたのトラッシュから＜悪魔＞のシグニ１枚を対象とし、それを手札に加える。②次のターンの間、対戦相手の場にあるシグニの基本レベルは１になる。（場に出たあとでレベルが１になる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    s.a=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    s.b=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
  end)
  e1:SetOperation(function(e,tp)
    if s.a and s.a:IsRelateToEffect(e) then Duel.Banish(s.a) end
    if s.b and s.b:IsRelateToEffect(e) then
      -- [まで] ターン終了時まで
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_CHANGE_LEVEL)
      e1:SetValue(1)
      e1:SetReset(RESET_PHASE+PHASE_END)
      s.b:RegisterEffect(e1)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e2:SetOperation(function(e,tp)
    if e:GetLabel()==0 then
      local x=Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_AKUMA)) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
      if x then Duel.SendToHand(x) end
      return
    end
    -- [の間] 「次のターンの間」
    local now=Duel.GetTurnCount()
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CHANGE_LEVEL)
    e1:SetTargetRange(0,LOCATION_SZONE)
    e1:SetTarget(function(e,x) return x:IsSigni() end)
    e1:SetCondition(function() return Duel.GetTurnCount()==now+1 end)
    e1:SetValue(1)
    e1:SetReset(RESET_PHASE+PHASE_END,2)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e2)
end
