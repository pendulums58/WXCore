-- SPK01-10 羅植　ミズバショウ（パーティーパックVol.4）
-- 【出】：あなたのデッキの上からカードを２枚エナゾーンに置く。ターン終了時、それらをあなたのエナゾーンからトラッシュに置く。このターン、あなたは１以上のエナコストを支払えない。
-- （エナコストは《白》《赤》《青》《緑》《黒》《無》で表記される）
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,2)
    local put={}
    if g:GetCount()>0 then
      Duel.SendToEna(g)
      for x in g:Iter() do if x:IsLocation(LOCATION_ENA) then put[#put+1]=x end end
    end
    -- [の間] 「このターン」 0인 코스트는 낼 수 있다(FAQ 1)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_NO_ENA_PAY)
    e1:SetTargetRange(1,0)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    if #put==0 then return end
    -- 턴 종료 시에 그것들을 트래시에. 다른 곳에 갔다 온 것은 다른 카드(FAQ 5)
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_TURN_END)
    e2:SetOperation(function()
      local t=Group.CreateGroup()
      for _,x in ipairs(put) do if x:IsLocation(LOCATION_ENA) then t:AddCard(x) end end
      if t:GetCount()>0 then Duel.SendToTrash(t,REASON_EFFECT) end
    end)
    e2:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e2,tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
end
