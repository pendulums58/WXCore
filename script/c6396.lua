-- WXK03-022 コードアクセル　バケット・WE
-- 【自】：このシグニがドライブ状態になったとき、カードを２枚引き、手札を１枚捨てる。
-- 【自】：このシグニがアタックしたとき、ターン終了時まで、対象のあなたのセンタールリグ１体は対象のあなたの＜乗機＞のシグニ１体に乗ってもよい。
-- 【自】：このシグニがバニッシュされたとき、ターン終了時まで、対象のあなたのセンタールリグ１体は対象のあなたの＜乗機＞のシグニ１体に乗ってもよい。
-- （ルリグがすでに他のシグニに乗っている場合は乗り換える）
-- ライフバースト：あなたのトラッシュから＜乗機＞のシグニを２枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_DRIVE)
  e1:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,2)
    aux.Discard(tp,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetOperation(function(e,tp,eg)
    local x=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_JOUKI) end,tp,LOCATION_SZONE,0,0,1,nil):GetFirst()
    if x and Duel.SelectYesNo(tp) then Duel.Ride(x) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_BANISHED)
  e3:SetOperation(function(e,tp,eg)
    local x=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_JOUKI) end,tp,LOCATION_SZONE,0,0,1,nil):GetFirst()
    if x and Duel.SelectYesNo(tp) then Duel.Ride(x) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e3)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_JOUKI) end,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e9)
end
