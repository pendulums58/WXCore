-- WDK15-007 フォトジェニック・バリアー
-- ベット―《コインアイコン》（このアーツを使用する際に《コインアイコン》を支払ってもよい）
-- あなたがベットする場合、このアーツの使用コストは《黒×2》減る。
-- あなたのトラッシュから対象の＜ウェポン＞のシグニ１枚を場に出し、あなたのトラッシュから対象のシグニを２枚までそのシグニの下に置く。
local s,id=GetID()
s.weapon=aux.ClassFilter(0,RACE_WEAPON)  -- ＜ウェポン＞のシグニ
s.rise=function(x) return x:IsSigni() and x:HasRiseIcon() and x:IsColor(COLOR_BLACK) end  -- 《ライズアイコン_黒》を持つシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(1)
  e1:SetBetCost("{B}")
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local a=Duel.SelectTarget(tp,s.weapon,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,0,2,a)
  end)
  -- 라이즈 시그니는 나중에 놓는 카드로 조건을 채울 수 없다(FAQ 1). 아래에 놓은 뒤 【出】이 발동한다(FAQ 2)
  e1:SetOperation(function(e,tp)
    local first=Duel.GetFirstTarget()
    if not (first and first:IsRelateToEffect(e)) then return end
    Duel.PutOnField(first,tp)
    if not first:IsLocation(LOCATION_SZONE) then return end
    local g=Duel.GetTargets():Filter(function(x) return x~=first and x:IsRelateToEffect(e) and x:IsLocation(LOCATION_TRASH) end,nil)
    if g:GetCount()>0 then Duel.PutUnder(first,g) end
  end)
  c:RegisterEffect(e1)
end
