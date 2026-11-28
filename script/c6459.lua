-- WXK04-003 エルドラ　オーバークロック
-- 【デコレ】
-- 【自】《ターン１回》：あなたのシグニ１体に【アクセ】が付いたとき、以下の３つから１つを選ぶ。①対戦相手のシグニ１体を対象とし、それをダウンする。②カードを１枚引く。③対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－5000する。
-- 【起】《ゲーム１回》サプライズ《コインアイコン》：あなたのデッキの上からカードを４枚見る。その中から好きな枚数の＜調理＞のシグニを場に出し、その後、好きな枚数の＜調理＞のシグニをあなたの＜調理＞のシグニの【アクセ】にする。残りをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddDecore(c,aux.Ability(id,0))
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ACCE)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg) local h=eg:GetFirst():GetAcceHost() return h and h:GetControler()==tp end)
  e1:SetOperation(function(e,tp,eg)
    local m=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
    if m==1 then Duel.Draw(tp,1) return end
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if not tc then return end
    if m==0 then Duel.Down(tc) else aux.AddPower(e,tc,-5000) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1,true)
  e2:SetCoinCost(1)
  e2:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,4)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    for x in Duel.SelectCards(tp,g:Filter(function(x) return x:IsSigni() and x:IsClass(0,RACE_CHOURI) end,nil),0,3):Iter() do Duel.PutOnField(x,tp) end
    local rest=g:Filter(function(y) return y:IsLocation(LOCATION_MDECK) and (function(x) return x:IsSigni() and x:IsClass(0,RACE_CHOURI) end)(y) end,nil)
    for x in Duel.SelectCards(tp,rest,0,rest:GetCount()):Iter() do
      local host=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(h) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_CHOURI) end)(h) and h:GetAcceHost()==nil and Duel.GetMatchingGroup(function(a) return a:GetAcceHost()==h end,tp,LOCATION_ACCE,0,nil):GetCount()==0 end,tp,LOCATION_SZONE,0,nil),0,1):GetFirst()
      if host then Duel.Acce(x,host) end
    end
    local left=g:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if left:GetCount()>0 then Duel.SendToTrash(left,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
end
