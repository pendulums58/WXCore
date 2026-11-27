-- WX17-033 コードイート　キャビアラ
-- 【出】：あなたのデッキの上からカードを３枚見て《アクセアイコン》を持つシグニ１枚をこのシグニの【アクセ】にする。残りを好きな順番でデッキの一番下に置く。
-- 【起】《メインフェイズアイコン》《アタックフェイズアイコン》《緑》《緑》《無》：あなたのシグニ１体を対象とし、このカードをエナゾーンからそれの【アクセ】にする。
-- 【常】：これにアクセされている＜調理＞のシグニのパワーを＋1000する。
-- 【自】：このカードが【アクセ】として＜調理＞のシグニに付いたとき、このシグニにアクセされているシグニよりパワーの低い対戦相手のシグニ１体を対象とし、それをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local x=Duel.SelectCards(tp,g:Filter(function(c) return c:IsSigni() and c:HasAcceIcon() end,nil),1,1):GetFirst()
    if x and h:IsLocation(LOCATION_SZONE) then Duel.Acce(x,h) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
  end)
  c:RegisterEffect(e1)
  aux.AddAcce(c,aux.Ability(id,1),"{G}{G}{C}")
  -- [の間] 【常】
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EFFECT_UPDATE_POWER)
  e2:SetRange(LOCATION_ACCE)
  e2:SetTargetRange(LOCATION_SZONE,0)
  e2:SetTarget(function(e,x) return x==e:GetHandler():GetAcceHost() and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_CHOURI)) end)(x) end)
  e2:SetValue(1000)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetCode(EVENT_ACCE)
  e3:SetRange(LOCATION_ACCE)
  e3:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x==e:GetHandler():GetAcceHost() and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_CHOURI)) end)(x) end)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local host=e:GetHandler():GetAcceHost()
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and host and x:GetPower()<host:GetPower() end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToEna(tc) end
  end)
  c:RegisterEffect(e3)
end
