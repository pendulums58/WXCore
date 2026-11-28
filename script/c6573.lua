-- WXK05-031 讃の遊　ブリキロボ
-- 【出】：このシグニがデッキから場に出た場合、あなたのデッキから＜遊具＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- 【起】《白》：このシグニをデッキの一番下に置く。あなたのデッキの上からカードを３枚見る。その中から＜遊具＞のシグニ１枚を公開し手札に加え、残りを好きな順番でデッキの一番上に戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_MDECK) end)
  e1:SetOperation(function(e,tp,eg)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_YUGU) end,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetEnaCost("{W}")
  e2:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then Duel.SendToDeckBottom(h,false) end
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local x=Duel.SelectCards(tp,g:Filter(function(x) return x:IsSigni() and x:IsClass(0,RACE_YUGU) end,nil),0,1)
    if x:GetCount()>0 then Duel.RevealCards(x) Duel.SendToHand(x) end
    local rest=g:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then aux.ToDeckTopInOrder(tp,rest) end
  end)
  c:RegisterEffect(e2)
end
