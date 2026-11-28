-- WXK09-003 回廊回路
-- あなたのセンタールリグが＜ピルルク＞の場合、このアーツの使用コストは《緑×2》減る。
-- 対戦相手のシグニ１体を対象とし、それをエナゾーンに置く。その後、対戦相手のセンタールリグが白の場合、対戦相手のシグニ１体を対象とし、それを手札に戻す。赤の場合、対戦相手のライフクロス１枚をエナゾーンに置く。青の場合、対戦相手は手札を３枚捨てる。緑の場合、カードを３枚引き、あなたのトラッシュからシグニを３枚まで対象とし、それらをエナゾーンに置く。黒の場合、あなたのトラッシュからシグニ１枚を対象とし、それを場に出す。無色の場合、対戦相手のシグニ１体を対象とし、それをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  -- 센터 루리그 색마다 추가 효과(백·적·청·녹·흑)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToEna(tc) end
    local lc=Duel.GetMatchingGroup(nil,1-tp,LOCATION_LRIG,0,nil):GetFirst()
    if not lc then return end
    if lc:IsColor(COLOR_WHITE) then local x=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() if x then Duel.SendToHand(x) end end
    if lc:IsColor(COLOR_RED) then local life=Duel.GetMatchingGroup(nil,1-tp,LOCATION_LIFE,0,nil) if life:GetCount()>0 then Duel.SendToEna(Duel.SelectCards(tp,life,1,1)) end end
    if lc:IsColor(COLOR_BLUE) then aux.Discard(1-tp,3) end
    if lc:IsColor(COLOR_GREEN) then
      Duel.Draw(tp,3)
      local g=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,0,3,nil)
      if g:GetCount()>0 then Duel.SendToEna(g) end
    end
    if lc:IsColor(COLOR_BLACK) then local x=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil):GetFirst() if x then Duel.PutOnField(x,tp) end end
    if lc:GetColor()==0 then local x=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() if x then Duel.SendToTrash(x,REASON_EFFECT) end end
  end)
  c:RegisterEffect(e1)
  aux.SetCostBy(e1,function(e,tp,base) if (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_PIRULUK) end)() then return Duel.ReduceCost(base,"{G}{G}",1) end return base end)
end
