-- WXK10-085 小罠　トカゲビル
-- 【出】：あなたのデッキの上からカードを２枚トラッシュに置く。その後、この方法でトラッシュに置かれたシグニのレベルの合計が４の場合、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－2000する。レベルの合計が６の場合、【エナチャージ１】をする。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,2)
    if g:GetCount()==0 then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    local n=0
    for x in g:Iter() do if x:IsSigni() then n=n+x:GetLevel() end end
    if n==4 then
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then aux.AddPower(e,tc,-2000) end
    elseif n==6 then Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e9)
end
