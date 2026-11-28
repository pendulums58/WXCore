-- WXK06-001 プロミス・フリーダム
-- あなたのセンタールリグが＜エマ＞の場合、このアーツの使用コストは《白×2》減る。
-- 対象の対戦相手のシグニ１体を手札に戻す。あなたのデッキから白のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。ターン終了時まで、対象の対戦相手のセンタールリグ１体は「【常】：アタックできない。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
    Duel.SelectTarget(tp,nil,tp,0,LOCATION_LRIG,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    for x in Duel.GetTargets():Iter() do
      if x:IsRelateToEffect(e) then
        if x:IsLocation(LOCATION_SZONE) then Duel.SendToHand(x)
        else
          -- [まで] ターン終了時まで
          local e1=Effect.CreateEffect(e:GetHandler())
          e1:SetType(EFFECT_TYPE_SINGLE)
          e1:SetCode(EFFECT_CANNOT_ATTACK)
          e1:SetReset(RESET_PHASE+PHASE_END)
          x:GrantEffect(e1)
        end
      end
    end
    aux.SearchToHand(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_WHITE) end,1)
  end)
  c:RegisterEffect(e1)
  aux.SetCostBy(e1,function(e,tp,base) if (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_EMMA) end)() then return Duel.ReduceCost(base,"{W}{W}",1) end return base end)
end
