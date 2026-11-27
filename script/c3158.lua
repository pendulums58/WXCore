-- WX20-072 コードイート　チョコプレート
-- 【出】：あなたのデッキの上からカードを５枚見る。その中からカード名に《ウェディング》を含むシグニ１枚を公開し手札に加えるかエナゾーンに置く。残りをシャッフルしてデッキの一番下に置く。
-- 【起】《緑》：あなたのシグニ１体を対象とし、このカードをエナゾーンからそれの【アクセ】にする。
-- 【常】：これにアクセされている《コードオーダー ウェディング》のパワーを＋1000し、それは「【自】：このシグニがアタックしたとき、自身のパワー以下の対戦相手のシグニ１体を対象とし、それをバニッシュする。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,5)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local x=Duel.SelectCards(tp,g:Filter(function(x) return x:IsSigni() and aux.NameHas(x,"ウェディング") end,nil),0,1):GetFirst()
    if x then
      Duel.RevealCards(Group.CreateGroup(x))
      if Duel.SelectYesNo(tp) then Duel.SendToHand(x) else Duel.SendToEna(x) end
    end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(rest,true) end
  end)
  c:RegisterEffect(e1)
  aux.AddAcce(c,aux.Ability(id,1),"{G}")
  -- [の間] 【常】 붙은 《コードオーダー　ウェディング》
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EFFECT_UPDATE_POWER)
  e2:SetRange(LOCATION_ACCE)
  e2:SetTargetRange(LOCATION_SZONE,0)
  e2:SetTarget(function(e,x) return x==e:GetHandler():GetAcceHost() and x:IsCardName(583) end)
  e2:SetValue(1000)
  c:RegisterEffect(e2)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetCode(EVENT_ATTACK)
  g:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=e:GetHandler():GetPower() end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  g:SetOperation(aux.BanishOp)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EFFECT_GRANT)
  e3:SetRange(LOCATION_ACCE)
  e3:SetTargetRange(LOCATION_SZONE,0)
  e3:SetTarget(function(e,x) return x==e:GetHandler():GetAcceHost() and x:IsCardName(583) end)
  e3:SetLabelObject(g)
  c:RegisterEffect(e3)
end
