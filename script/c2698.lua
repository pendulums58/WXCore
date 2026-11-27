-- WX14-037 進撃の炎軍
-- 以下の２つから１つを選ぶ。
-- ①対象のあなたのカード名に《フレイスロ》を含むシグニ１体をバニッシュする。そうした場合、対象の対戦相手のパワー7000以下のシグニ１体をバニッシュする。
-- ②あなたのカード名に《フレイスロ》を含むシグニ１体を対象とし、それをバニッシュする。そうした場合、あなたのデッキの上からカードを３枚公開する。その中からカード名に《フレイスロ》を含むシグニ１枚を手札に加え、残りを好きな順番でデッキの一番下に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    s.a=Duel.SelectTarget(tp,function(x) return x:IsSigni() and aux.NameHas(x,"フレイスロ") end,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    s.b=e:GetLabel()==0 and Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=7000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() or nil
  end)
  e1:SetOperation(function(e,tp)
    if not (s.a and s.a:IsRelateToEffect(e)) or Duel.Banish(s.a)==0 then return end
    if e:GetLabel()==0 then
      if s.b and s.b:IsRelateToEffect(e) then Duel.Banish(s.b) end
      return
    end
    local g=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,3))
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local x=Duel.SelectCards(tp,g:Filter(function(x) return x:IsSigni() and aux.NameHas(x,"フレイスロ") end,nil),0,1)
    if x:GetCount()>0 then Duel.SendToHand(x) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
  end)
  c:RegisterEffect(e1)
end
