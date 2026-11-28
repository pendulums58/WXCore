-- WXK09-002 ホーリー・グランドスラム
-- あなたのセンタールリグが＜タマ＞の場合、このアーツの使用コストは《青×2》減る。
-- いずれかのプレイヤーのルリグトラッシュからコストの合計が５以下のアーツ１枚を対象とし、それをコストを支払わずに限定条件を無視して使用する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_ARTS) and select(2,x:GetEnaCost():gsub("{",""))<=5 end,tp,LOCATION_LTRASH,LOCATION_LTRASH,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.UseFree(tc,tp)
    end
  end)
  c:RegisterEffect(e1)
  aux.SetCostBy(e1,function(e,tp,base) if (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_TAMA) end)() then return Duel.ReduceCost(base,"{U}{U}",1) end return base end)
end
