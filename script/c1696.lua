-- WDK10-008 ヴェイパー・コントロール
-- ベット―《コインアイコン》《コインアイコン》
-- 対戦相手のトラッシュにあるカード３枚を対象とし、それらをゲームから除外する。その後、それらがそれぞれ共通する色を持つ場合、あなたのトラッシュから黒のシグニを２枚まで対象とし、それらを手札に加える。あなたがベットしていた場合、代わりにあなたのトラッシュから黒のシグニを４枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 상대 트래시가 2장 이하면 쓸 수 없다(FAQ 1)
  e1:SetCondition(function(e,tp) return Duel.GetMatchingGroup(nil,tp,0,LOCATION_TRASH,nil):GetCount()>=3 end)
  e1:SetBet(2)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,0,LOCATION_TRASH,3,3,nil)
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()==0 then return end
    -- 3장 모두 공통된 색. 무색은 색이 아니다(FAQ 2·3)
    local col=g:GetCount()==3 and COLOR_WHITE+COLOR_RED+COLOR_BLUE+COLOR_GREEN+COLOR_BLACK or 0
    for x in g:Iter() do col=col&x:GetColor() end
    Duel.Exclude(g)
    if col==0 then return end
    local tg=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,tp,LOCATION_TRASH,0,0,Duel.IsBet() and 4 or 2,nil)
    if tg:GetCount()>0 then Duel.SendToHand(tg) end
  end)
  c:RegisterEffect(e1)
end
