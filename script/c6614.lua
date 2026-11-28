-- WXK05-072 幻水　カワウソ
-- 【出】：あなたの＜水獣＞のシグニ１体を対象とし、ターン終了時まで、それのパワーを＋5000する。
-- 【自】：このカードがあなたの効果によって手札から公開されたとき、《緑》を支払い、手札から《幻水　カワウソ》を１枚捨ててもよい。そうした場合、ターン終了時まで、あなたのすべての＜水獣＞のシグニのパワーを＋5000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_SUIJU) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,5000)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_REVEALED_FROM_HAND)
  e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==tp and eg:IsContains(e:GetHandler()) end)
  e2:SetOperation(function(e,tp,eg)
    local h=Duel.GetMatchingGroup(function(x) return x:IsCardName(id) end,tp,LOCATION_HAND,0,nil)
    if h:GetCount()==0 or not Duel.CanPayEna(tp,"{G}") or not Duel.SelectYesNo(tp) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{G}"),REASON_COST)
    if Duel.SendToTrash(Duel.SelectCards(tp,h,1,1),REASON_EFFECT+REASON_DISCARD)>0 then
      for x in Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_SUIJU) end,tp,LOCATION_SZONE,0,nil):Iter() do aux.AddPower(e,x,5000) end  -- [まで] ターン終了時まで
    end
  end)
  c:RegisterEffect(e2)
end
