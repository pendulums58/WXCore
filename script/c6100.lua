-- WXEX1-66 羅原　B
-- 【自】：このシグニがアタックしたとき、次のあなたのターンまで、対戦相手はスペルを使用できない。
-- 【出】：対戦相手のシグニ１体を対象とし、あなたのデッキの上からカードを４枚公開する。この方法で＜原子＞のシグニが４種類公開された場合、それをバニッシュする。公開したカードをシャッフルしてデッキの一番下に置く。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    -- [まで] 次のあなたのターンまで、対戦相手はスペルを使用できない
    local e0=Effect.CreateEffect(e:GetHandler())
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_CANNOT_USE)
    e0:SetTargetRange(0,LOCATION_HAND)
    e0:SetTarget(function(ef,x) return x:IsType(TYPE_SPELL) end)
    e0:SetReset(RESET_PHASE+PHASE_END+RESET_MY_TURN)
    Duel.RegisterEffect(e0,tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    local g=Duel.GetDecktopGroup(tp,4)
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local seen,n={},0
    for x in g:Iter() do
      if x:IsSigni() and x:IsClass(0,RACE_GENSHI) and not seen[x:GetCode()] then
        seen[x:GetCode()]=true
        n=n+1
      end
    end
    if n>=4 and tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
    Duel.SendToDeckBottom(g,true)
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e9)
end
