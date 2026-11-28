-- WXK04-044 紅蓮の使い魔　オズマ姫
-- 【常】：このシグニは血晶武装状態であるかぎり、「【自】：このシグニが正面のシグニ１体をバニッシュしたとき、このシグニをアップする。」を得る。
-- 【出】手札を１枚捨てる：あなたのデッキの上からカードを５枚見る。その中から＜紅蓮＞のシグニ１枚を公開し手札に加え、残りをシャッフルしてデッキの一番下に置く。
local s,id=GetID()
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Stringid(id,0))
  g:SetCode(EVENT_BANISHED)
  g:SetRange(LOCATION_SZONE)
  g:SetCondition(function(e,tp,eg,ep) return ep~=tp and Duel.GetBanisher()==e:GetHandler() end)
  g:SetOperation(function(e) local h=e:GetHandler() if h:IsLocation(LOCATION_SZONE) then Duel.Up(h) end end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():IsBloodArmed() end)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetCost(aux.DiscardCost(1))
  e2:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,5)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local x=Duel.SelectCards(tp,g:Filter(function(x) return x:IsSigni() and x:IsClass(0,RACE_GUREN) end,nil),0,1)
    if x:GetCount()>0 then Duel.RevealCards(x) Duel.SendToHand(x) end
    local rest=g:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(rest,true) end
  end)
  c:RegisterEffect(e2)
end
