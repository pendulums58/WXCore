-- WDK01-007 質実轟健
-- ベット―《コインアイコン》
-- あなたがベットする場合、このアーツの使用コストは《赤×0》になる。
-- あなたのドライブ状態のシグニ１体を対象とし、ターン終了時まで、それは【ダブルクラッシュ】を得る。そのシグニがレベル３以上の場合、代わりにターン終了時まで、それは【トリプルクラッシュ】を得る。
-- （【ダブルクラッシュ】を持つシグニがアタックによってダメージを与えた場合ライフクロスを１枚ではなく２枚クラッシュする。【トリプルクラッシュ】の場合３枚クラッシュする）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(1)
  e1:SetBetCost("")
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsDrive() end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  -- [まで] 그 뒤 ドライブ状態가 아니게 돼도 잃지 않는다(FAQ 3)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.GrantKeyword(e,tc,tc:GetLevel()>=3 and EFFECT_TRIPLE_CRUSH or EFFECT_DOUBLE_CRUSH) end
  end)
  c:RegisterEffect(e1)
end
