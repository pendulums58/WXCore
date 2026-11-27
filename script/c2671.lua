-- WX14-006A 緑肆ノ遊　アスレ【ＨＡＲＤ】
-- 【出現条件】《メインフェイズアイコン》合計３枚のレゾナではない＜遊具＞のシグニをあなたの手札とエナゾーンと場からトラッシュに置く
-- 【自】：あなたのシグニ１体がアタックしたとき、あなたのデッキの一番上のカードをエナゾーンに置く。
-- 【出】：ターン終了時まで、あなたのすべての＜遊具＞のシグニは「【自】：このシグニが対戦相手のシグニ１体をバニッシュしたとき、このシグニをアップする。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,3,aux.NonResonaClass(RACE_YUGU),LOCATION_HAND+LOCATION_ENA+LOCATION_SZONE)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()==tp and x:IsSigni() end)
  e1:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    -- [まで] 처리할 때 장에 있는 ＜遊具＞
    for tc in Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end,tp,LOCATION_SZONE,0,nil):Iter() do
      local g=Effect.CreateEffect(e:GetHandler())
      g:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
      g:SetCode(EVENT_BANISHED)
      g:SetRange(LOCATION_SZONE)
      g:SetCondition(function(e2,tp2,eg) return eg:GetFirst():GetOwner()~=tp2 and Duel.GetBanisher()==e2:GetHandler() end)
      g:SetOperation(function(e2) local h=e2:GetHandler() if h:IsLocation(LOCATION_SZONE) then Duel.Up(h) end end)
      g:SetReset(RESET_PHASE+PHASE_END)
      tc:GrantEffect(g)
    end
  end)
  c:RegisterEffect(e2)
end
