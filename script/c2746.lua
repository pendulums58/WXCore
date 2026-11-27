-- WX15-003 メル＝マティーニ
-- 【自】：アクセされているあなたのシグニ１体があなたの効果以外によってバニッシュされたとき、カードを１枚引いてもよい。
-- 【自】：あなたのメインフェイズ開始時、あなたのデッキの上からカードを３枚公開してもよい。その中から《アクセアイコン》を持つカード１枚をエナゾーンに置き、残りを好きな順番でデッキの一番下に置く。
-- 【起】ベルセルク《コインアイコン》《コインアイコン》《コインアイコン》：次のターンの間、対戦相手はアーツとスペルと【起】能力を使用できず、シグニは可能ならばアタックしなければならない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) local x=eg:GetFirst() return x:GetOwner()==tp and x:IsPreviousAcce() and (r&REASON_EFFECT==0 or rp~=tp) end)
  e1:SetOperation(function(e,tp)
    if Duel.SelectYesNo(tp) then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_PHASE_START+PHASE_MAIN)
  e2:SetRange(LOCATION_LRIG)
  e2:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e2:SetOperation(function(e,tp)
    if not Duel.SelectYesNo(tp) then return end
    local g=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,3))
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local x=Duel.SelectCards(tp,g:Filter(Card.HasAcceIcon,nil),1,1)
    if x:GetCount()>0 then Duel.SendToEna(x) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCoinCost(3)
  e3:SetOperation(function(e,tp)
    -- [の間] 「次のターンの間」
    for _,code in ipairs({EFFECT_CANNOT_USE,EFFECT_DISABLE_ABILITY,EFFECT_MUST_ATTACK}) do
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD)
      e1:SetCode(code)
      if code==EFFECT_CANNOT_USE then
        e1:SetTargetRange(0,1)
      else
        e1:SetTargetRange(0,LOCATION_SZONE+LOCATION_LRIG)
        e1:SetTarget(function(e2,x) return code==EFFECT_DISABLE_ABILITY or x:IsSigni() end)
        if code==EFFECT_DISABLE_ABILITY then e1:SetValue(ABILITY_IGNITION) end
      end
    local now=Duel.GetTurnCount()
    e1:SetCondition(function() return Duel.GetTurnCount()==now+1 end)
    e1:SetReset(RESET_PHASE+PHASE_END,2)
      Duel.RegisterEffect(e1,tp)
    end
  end)
  c:RegisterEffect(e3)
end
