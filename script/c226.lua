-- WXK02-027 デッド・ゲート
-- このアーツを使用する際、使用コストとして追加で《黒×1》を支払ってもよい。
-- 対象のあなたのセンタールリグよりレベルが１つ高い対戦相手のシグニ１体をトラッシュに置く。追加で《黒×1》を支払っていた場合、あなたのトラッシュから対象のあなたのセンタールリグよりレベルが１つ低いシグニ１枚を場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local base=Duel.GetUseCost()
    local more=Duel.CanPayEna(tp,base.."{B}") and Duel.SelectYesNo(tp)
    if more then Duel.SetUseCost(base.."{B}") end
    e:SetLabel(more and 1 or 0)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
  local lv=lc and lc:GetLevel() or 0
  Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()==lv+1 end,tp,0,LOCATION_SZONE,1,1,nil)
  if e:GetLabel()==1 then Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()==lv-1 end,tp,LOCATION_TRASH,0,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp,eg)
    -- 상대 시그니가 없어도 낸다(FAQ 3)
    for x in Duel.GetTargets():Iter() do
      if x:IsRelateToEffect(e) then
        if x:IsLocation(LOCATION_SZONE) then Duel.SendToTrash(x,REASON_EFFECT) else Duel.PutOnField(x,tp) end
      end
    end
  end)
  c:RegisterEffect(e1)
end
