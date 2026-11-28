-- PR-K043 爪英の忠誠　風の姉妹（カードゲーマーvol.43 付録）
-- 【自】：このシグニがアタックしたとき、対戦相手のレベル３以下のシグニ１体を対象とし、手札からレベルの合計が７になるようにシグニを好きな枚数捨ててもよい。そうした場合、それをデッキの一番下に置く。
-- 【出】《無》《無》《無》：あなたのデッキからレベルの合計が５の無色ではないシグニ２枚を探して公開し手札に加え、デッキをシャッフルする。
-- ライフバースト：どちらか１つ選ぶ。①カードを１枚引く。②【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    Duel.SetSelectCheck(function(sg) local n=0 for x in sg:Iter() do n=n+x:GetLevel() end return sg:GetCount()==0 or n==7 end)
    local d=Duel.SelectDiscard(tp,0,99,Card.IsSigni)
    if d:GetCount()==0 then return end
    Duel.SendToTrash(d,REASON_EFFECT+REASON_DISCARD)
    Duel.SendToDeckBottom(tc,false)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{C}{C}{C}")
  e2:SetOperation(function(e,tp)
    Duel.SetSelectCheck(function(sg) local n=0 for x in sg:Iter() do n=n+x:GetLevel() end return sg:GetCount()==0 or (sg:GetCount()==2 and n==5) end)
    local g=aux.Search(tp,function(x) return x:IsSigni() and x:GetColor()~=0 end,2)
    if g:GetCount()>0 then
      Duel.RevealCards(g)
      Duel.SendToHand(g)
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then Duel.Draw(tp,1) else Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e3)
end
