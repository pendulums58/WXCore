-- WX22-010 アイヤイ★ロイヤルフラッシュ
-- 【自】：各アタックフェイズ開始時、あなたのルリグデッキから＜遊具＞のレゾナ１枚を出現条件を無視して場に出す。
-- 【起】《ターン１回》《緑》：あなたのエナゾーンからシグニを３枚まで対象とし、それらを手札に加える。
-- 【起】《ターン１回》エクシード２：このターンの最初のアタックフェイズの後に、追加のアタックフェイズを加える。この方法で加えたアタックフェイズの開始時、あなたのすべての＜遊具＞のシグニをチェックゾーンに置く。その後、それらを場に出し、このルリグをアップする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_LRIG)
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetCondition(function(e,tp) return true end)
  e1:SetOperation(function(e,tp)
    local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(c) return c:IsType(TYPE_RESONA) and c:IsClass(0,RACE_YUGU) end,tp,LOCATION_LDECK,0,nil),0,1):GetFirst()
    if x then Duel.PutOnField(x,tp,false) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetEnaCost("{G}")
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_ENA,0,0,3,nil)
  end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e2)
  -- 【起】 엑시드 2 「追加のアタックフェイズ」는 아직(근사 없음)
end
