-- WX16-004 ブレイクスルー・ブルー
-- ベット―《コインアイコン》or《コインアイコン》《コインアイコン》
-- 対象の対戦相手のシグニ１体をダウンする。
-- あなたがベットしていた場合、追加で対象の対戦相手のシグニ１体をダウンする。
-- あなたが《コインアイコン》《コインアイコン》をベットしていた場合、追加でターン終了時まで、あなたのセンタールリグは「【常】：ホログラフの効果によってあなたのデッキの一番上を公開する場合、代わりにあなたはデッキの上からカードを３枚見て、それらを好きな順番でデッキの上に戻してからデッキの一番上を公開する。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local n=Duel.IsBet() and 2 or 1
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,n,n,nil)
  end)
  -- 「《コイン》《コイン》をベット」는 아직(1개로만 ベット. 근사)
  e1:SetOperation(function(e,tp)
    for x in Duel.GetTargets():Iter() do if x:IsRelateToEffect(e) then Duel.Down(x) end end
  end)
  c:RegisterEffect(e1)
end
