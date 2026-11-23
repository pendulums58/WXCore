-- WDK08-Y06 遮断装甲
-- ベット―《コインアイコン》
-- あなたがベットする場合、このアーツの使用コストは《緑×1》になる。
-- あなたのエナゾーンから＜水獣＞のシグニ１枚を対象とし、それを場に出す。ターン終了時まで、それのパワーを＋10000する。
local s,id=GetID()
s.suiju=aux.ClassFilter(0,RACE_SUIJU)  -- ＜水獣＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(1)
  e1:SetBetCost("{G}")  -- 《緑》×３ → 《緑×1》(FAQ 1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,s.suiju,tp,LOCATION_ENA,0,1,1,nil)
  end)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- 빈 시그니 존이 없거나 레벨·리미트를 넘으면 내지 못하고 끝(FAQ 2·3)
function s.op(e,tp)
  local tc=Duel.GetFirstTarget()
  if not (tc and tc:IsRelateToEffect(e) and Duel.PutOnField(tc,tp)) then return end
  aux.AddPower(e,tc,10000)  -- [まで] ターン終了時まで
end
