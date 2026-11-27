-- WX18-006 赤羅星　≡ゴールデンサン≡
-- 【出現条件】《メインフェイズアイコン》合計３枚のレゾナではない＜宇宙＞のシグニをあなたの手札と場からトラッシュに置く
-- 【自】：このシグニがアタックしたとき、あなたのデッキの上からカードを３枚トラッシュに置く。この方法でトラッシュに置いたシグニのレベルの合計が７以上の場合、対戦相手は手札を１枚捨てる。１０以上の場合、ターン終了時まで、このシグニは【アサシン】を得る。１２以上の場合、ターン終了時まで、このシグニは【トリプルクラッシュ】を得る。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,3,aux.NonResonaClass(RACE_UCHU),LOCATION_HAND+LOCATION_SZONE)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    local sum=0
    for x in g:Iter() do if x:IsSigni() then sum=sum+x:GetLevel() end end
    local h=e:GetHandler()
    if sum>=7 then aux.Discard(1-tp,1) end
    if sum>=10 and h:IsLocation(LOCATION_SZONE) then aux.GrantKeyword(e,h,EFFECT_ASSASSIN) end
    if sum>=12 and h:IsLocation(LOCATION_SZONE) then aux.GrantKeyword(e,h,EFFECT_TRIPLE_CRUSH) end
  end)
  c:RegisterEffect(e1)
end
