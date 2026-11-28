-- WXK10-018 翠焼の記憶　リル＆メル
-- 【出】：以下の２つから１つを選ぶ。あなたのシグニ１体を対象とし、ターン終了時まで、それは選んだ能力を得る。
-- ①【アサシン】②【ランサー】
-- 【起】《ターン１回》あなたのシグニに付いているカード１枚か、あなたのシグニの下にあるカード１枚をトラッシュに置く：カードを１枚引く。
-- 【起】このキーを場からルリグトラッシュに置く：あなたのデッキの一番上のカードをライフクロスに加える。手札を２枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    local m=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    if tc then aux.GrantKeyword(e,tc,m==0 and EFFECT_ASSASSIN or EFFECT_LANCER) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_KEY)
  e2:SetCountLimit(1)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=(function() local g=Group.CreateGroup() for x in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do for y in x:GetUnderGroup():Iter() do g:AddCard(y) end end return g end)()
    for x in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do
      if x:GetCharm() then g:AddCard(x:GetCharm()) end
      for y in Duel.GetMatchingGroup(function(z) return z:GetAcceHost()==x end,tp,LOCATION_ACCE,0,nil):Iter() do g:AddCard(y) end
    end
    if chk==0 then return g:GetCount()>0 end
    Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_COST)
  end)
  e2:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_KEY)
  e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) end
    Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
  end)
  e3:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,1)
    if g:GetCount()>0 then Duel.SendToLife(g) end
    aux.Discard(tp,2)
  end)
  c:RegisterEffect(e3)
end
