-- WXK05-029 サーバント　G
-- 【常】：あなたのトラッシュにカード名に《サーバント》を含むシグニが１０種類以上あるかぎり、このシグニはすべての色を得る。
-- 【自】：このシグニがアタックしたとき、このシグニと共通する色を持つ対戦相手のシグニ１体を対象とし、それをトラッシュに置く。
-- 【起】《ターン１回》《無》《無》：あなたのデッキからそれぞれレベルの異なる、能力が同じシグニ４枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_ADD_COLOR)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e)
    local t,n={},0
    for x in Duel.GetMatchingGroup(function(y) return y:IsSigni() and aux.NameHas(y,"サーバント") end,e:GetHandlerPlayer(),LOCATION_TRASH,0,nil):Iter() do
      if not t[x:GetCode()] then t[x:GetCode()]=true n=n+1 end
    end
    return n>=10
  end)
  e1:SetValue(COLOR_WHITE+COLOR_RED+COLOR_BLUE+COLOR_GREEN+COLOR_BLACK)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local col=e:GetHandler():GetColor()
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetColor()&col~=0 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToTrash(tc,REASON_EFFECT)
    end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  -- 「能力が同じ」(근사: 이름에 サーバント가 든 시그니)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_SZONE)
  e3:SetCountLimit(1)
  e3:SetEnaCost("{C}{C}")
  e3:SetOperation(function(e,tp,eg)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and aux.NameHas(x,"サーバント") end,tp,LOCATION_MDECK,0,nil)
    Duel.SetSelectCheck(function(sg) return sg:GetCount()==0 or (sg:GetCount()==4 and aux.DistinctLevels(sg)) end)
    local x=Duel.SelectCards(tp,g,0,4)
    if x:GetCount()==4 then Duel.RevealCards(x) Duel.SendToHand(x) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e3)
end
