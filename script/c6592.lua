-- WXK05-050 羅植　ヤマレンゲ
-- 【起】《白》このシグニを場からトラッシュに置く：あなたのデッキの上からカードを３枚見て、その中から＜植物＞のシグニ１枚を場に出す。残りをシャッフルしてデッキの一番下に置く。
-- 【自】：このシグニが開花したとき、あなたの【シード】１枚を対象とし、《白》を支払ってもよい。そうした場合、それを開花し、あなたのデッキの一番上を見て、それを【シード】としてあなたのシグニゾーンに出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetEnaCost("{W}")
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_SZONE) end
    Duel.SendToTrash(e:GetHandler(),REASON_COST)
  end)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local x=Duel.SelectCards(tp,g:Filter(function(x) return x:IsSigni() and x:IsClass(0,RACE_SHOKUBUTSU) end,nil),1,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
    local rest=g:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(rest,true) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_BLOOM)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,LOCATION_SEED,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    if not (Duel.CanPayEna(tp,"{W}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{W}"),REASON_COST)
    Duel.Bloom(tc)
    local g=Duel.GetDecktopGroup(tp,1)
    local x=g:GetFirst()
    if x then Duel.ConfirmCards(tp,g) Duel.SetSeed(x,tp) end
  end)
  c:RegisterEffect(e2)
end
