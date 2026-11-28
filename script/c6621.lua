-- WXK06-003 リーサル・ブラック
-- あなたのセンタールリグが＜ウリス＞の場合、このアーツの使用コストは《黒×2》減る。
-- ターン終了時まで、対象の対戦相手のシグニ１体のパワーを－12000する。あなたのトラッシュから対象の黒のシグニ１枚を手札に加える。あなたのデッキの一番上のカードをライフクロスに加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    for x in Duel.GetTargets():Iter() do
      if x:IsRelateToEffect(e) then
        if x:IsLocation(LOCATION_SZONE) then aux.AddPower(e,x,-12000) else Duel.SendToHand(x) end
      end
    end
    local g=Duel.GetDecktopGroup(tp,1)
    if g:GetCount()>0 then Duel.SendToLife(g) end
  end)
  c:RegisterEffect(e1)
  aux.SetCostBy(e1,function(e,tp,base) if (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_URITH) end)() then return Duel.ReduceCost(base,"{B}{B}",1) end return base end)
end
