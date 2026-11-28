-- WXK05-027 幻水姫　オワンクラゲ
-- 【自】：各アタックフェイズ開始時、あなたのエナゾーンから《幻水姫　オワンクラゲ》以外のシグニを１枚まで対象とし、それを手札に加える。
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、《緑》を支払い、手札からそれぞれ名前の異なる＜水獣＞のシグニを４枚公開してもよい。そうした場合、それをエナゾーンに置く。
-- ライフバースト：あなたのトラッシュから＜水獣＞のシグニを２枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and not x:IsCardName(id) end,tp,LOCATION_ENA,0,0,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToHand(tc)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    local h=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_SUIJU) end,tp,LOCATION_HAND,0,nil)
    local names,k={},0
    for x in h:Iter() do if not names[x:GetCode()] then names[x:GetCode()]=true k=k+1 end end
    if not (tc and tc:IsRelateToEffect(e) and k>=4 and Duel.CanPayEna(tp,"{G}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{G}"),REASON_COST)
    Duel.SetSelectCheck(function(sg)
      if sg:GetCount()~=4 then return false end
      local u={}
      for x in sg:Iter() do if u[x:GetCode()] then return false end u[x:GetCode()]=true end
      return true
    end)
    local g=Duel.SelectCards(tp,h,4,4)
    if g:GetCount()<4 then return end
    Duel.RevealCards(g)
    Duel.SendToEna(tc)
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_SUIJU) end,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e9)
end
