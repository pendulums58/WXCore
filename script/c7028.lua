-- WXK10-054 弩書　ピカトリクス
-- 【ライズ】あなたの＜ウェポン＞のシグニ１体の上に置く
-- 【自】：このシグニがバニッシュされたとき、あなたのトラッシュからこのシグニの下にあった＜ウェポン＞のシグニ１枚を対象とし、それを手札に加える。
-- 【起】《ターン１回》あなたのシグニの下からカードを合計２枚トラッシュに置く：対戦相手のシグニ１体を対象とし、ターン終了時まで、それの基本パワーを０にする。
-- ライフバースト：対戦相手のシグニ１体を対象とし、ターン終了時まで、それの基本パワーを０にする。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddRise(c,function(x) return x:IsSigni() and x:IsClass(0,RACE_WEAPON) end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  -- 「このシグニの下にあった」(근사: 트래시의 ＜ウェポン＞ 1장)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_BANISHED)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_WEAPON) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToHand(tc)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=(function() local g=Group.CreateGroup() for x in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do for y in x:GetUnderGroup():Iter() do g:AddCard(y) end end return g end)()
    if chk==0 then return g:GetCount()>=2 end
    Duel.SendToTrash(Duel.SelectCards(tp,g,2,2),REASON_COST)
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_SET_BASE_POWER)
      e1:SetValue(0)
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:GrantEffect(e1)
    end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_SET_BASE_POWER)
      e1:SetValue(0)
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:GrantEffect(e1)
    end
  end)
  c:RegisterEffect(e9)
end
