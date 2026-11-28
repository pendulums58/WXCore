-- WXK01-037 コードアクセル　ロドローラ
-- 【自】《ターン１回》：あなたのシグニ１体が対戦相手のライフクロス１枚をクラッシュしたとき、そのシグニをバニッシュしてもよい。そうした場合、カードを２枚引く。
-- 【自】：あなたのターン終了時、手札を１枚捨ててもよい。そうした場合、あなたのデッキの上からシグニがめくれるまで公開する。そのシグニを場に出し、この方法で公開されたカードをトラッシュに置く。
-- ライフバースト：カードを１枚引く。あなたのライフクロスが４枚以下の場合、追加で【エナチャージ１】をする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_CRUSHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  -- 어택이 아니어도(FAQ 1)
  e1:SetCondition(function(e,tp,eg,ep) local x=Duel.GetCrusher() return ep~=tp and x and x:IsSigni() and x:GetControler()==tp end)
  e1:SetOperation(function(e,tp,eg)
    local x=Duel.GetCrusher()
    if x and x:IsLocation(LOCATION_SZONE) and Duel.SelectYesNo(tp) and Duel.Banish(x)>0 then Duel.Draw(tp,2) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_TURN_END)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e2:SetOperation(function(e,tp,eg)
    local h=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    if h:GetCount()==0 or not Duel.SelectYesNo(tp) or Duel.SendToTrash(Duel.SelectCards(tp,h,1,1),REASON_EFFECT+REASON_DISCARD)==0 then return end
    local seen,hit=Group.CreateGroup(),nil
    local n=Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil):GetCount()
    for i=1,n do
      local last=nil
      for y in Duel.GetDecktopGroup(tp,i):Iter() do last=y end
      seen:AddCard(last)
      if last:IsSigni() then hit=last break end
    end
    if seen:GetCount()==0 then return end
    Duel.RevealCards(seen)
    if hit then Duel.PutOnField(hit,tp) end
    local rest=seen:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()<=4 then Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e9)
end
