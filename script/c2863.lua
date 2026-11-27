-- WX16-045 コードイート　チョコスプ
-- 【出】手札から《アクセアイコン》を持つシグニを１枚捨てる：あなたのデッキから＜調理＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- 【起】《緑》《緑》：あなたのシグニ１体を対象とし、このカードをエナゾーンからそれの【アクセ】にする。
-- 【常】：これにアクセされている＜調理＞のシグニは「【自】：このシグニがアタックしたとき、自身のパワー以下の対戦相手のシグニ１体を対象とし、それをバニッシュする。」を得る。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(aux.DiscardCost(1,function(x) return x:IsSigni() and x:HasAcceIcon() end))
  e1:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_CHOURI)) end,1)
  end)
  c:RegisterEffect(e1)
  aux.AddAcce(c,aux.Ability(id,1),"{G}{G}")
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetCode(EVENT_ATTACK)
  g:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=e:GetHandler():GetPower() end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  g:SetOperation(aux.BanishOp)
  -- [の間] 【常】 이것이 붙은 ＜調理＞ 시그니가 얻는다
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_FIELD)
  e9:SetCode(EFFECT_GRANT)
  e9:SetRange(LOCATION_ACCE)
  e9:SetTargetRange(LOCATION_SZONE,0)
  e9:SetTarget(function(e,x) return x==e:GetHandler():GetAcceHost() and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_CHOURI)) end)(x) end)
  e9:SetLabelObject(g)
  c:RegisterEffect(e9)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e3)
end
