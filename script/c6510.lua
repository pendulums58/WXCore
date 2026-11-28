-- WXK04-054 幻水　プレシオ
-- 【常】：このシグニはパワーが10000以上であるかぎり、【ランサー】を得る。
-- 【自】：このカードがあなたの効果によって手札から公開されたとき、あなたの＜水獣＞のシグニ１体を対象とし、《緑》を支払い、手札から《幻水 プレシオ》を１枚捨ててもよい。そうした場合、ターン終了時まで、それは【ランサー】を得る。
-- ライフバースト：どちらか１つを選ぶ。①対戦相手のパワー12000以上のシグニ１体を対象とし、それをバニッシュする。②【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_LANCER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():GetPower()>=10000 end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_REVEALED_FROM_HAND)
  e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==tp and eg:IsContains(e:GetHandler()) end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_SUIJU) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    local h=Duel.GetMatchingGroup(function(x) return x:IsCardName(id) end,tp,LOCATION_HAND,0,nil)
    if not (tc and tc:IsRelateToEffect(e) and h:GetCount()>0 and Duel.CanPayEna(tp,"{G}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{G}"),REASON_COST)
    if Duel.SendToTrash(Duel.SelectCards(tp,h,1,1),REASON_EFFECT+REASON_DISCARD)>0 then aux.GrantKeyword(e,tc,EFFECT_LANCER) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e9:SetOperation(function(e,tp,eg)
    if e:GetLabel()==1 then Duel.EnaCharge(tp,1) return end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=12000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e9)
end
