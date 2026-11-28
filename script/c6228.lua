-- WXK01-045 超罠　ヤミガネ
-- 【自】：このシグニがアタックしたとき、このターンに場に出た対戦相手のシグニ１体を対象とし、《黒》を支払ってもよい。そうした場合、それをバニッシュする。
-- 【出】《黒》：対戦相手のシグニ１体を対象とし、それをトラッシュに置く。対戦相手は自分のデッキを上から、それ以下のレベルを持つシグニがめくれるまで公開し、そのシグニを場に出す。そのシグニの【出】能力は発動しない。この方法で公開されたカードをシャッフルしてデッキの一番下に置く。
-- ライフバースト：カードを１枚引く。あなたのライフクロスが４枚以下の場合、追加で【エナチャージ１】をする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsEnteredThisTurn() end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.CanPayEna(tp,"{B}") and Duel.SelectYesNo(tp) then
      Duel.SendToTrash(Duel.SelectEnaCost(tp,"{B}"),REASON_COST)
      Duel.Banish(tc)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{B}")
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    local lv=tc:GetLevel()
    if Duel.SendToTrash(tc,REASON_EFFECT)==0 then return end
    -- 없으면 공개한 것을 섞어 덱으로(FAQ 2)
    local p=1-tp
    local seen,hit=Group.CreateGroup(),nil
    local n=Duel.GetMatchingGroup(nil,p,LOCATION_MDECK,0,nil):GetCount()
    for i=1,n do
      local last=nil
      for y in Duel.GetDecktopGroup(p,i):Iter() do last=y end
      seen:AddCard(last)
      if last:IsSigni() and last:GetLevel()<=lv then hit=last break end
    end
    if seen:GetCount()==0 then return end
    Duel.RevealCards(seen)
    if hit then Duel.PutOnField(hit,p,true) end
    local rest=seen:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(rest,true) end
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
