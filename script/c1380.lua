-- WD23-020-E 幻水姫　グレホザメ
-- 【自】：あなたか対戦相手のライフバーストが発動したとき、カードを１枚引く。
-- 【自】《ターン１回》：アタックフェイズの間にあなたがカードを１枚以上引いたとき、このターンのアタックフェイズの間にあなたが引いたカードの枚数までの数のシグニを対象とし、それらをアップするかダウンする。
local s,id=GetID()
function s.initial_effect(c)
  -- 떠난 뒤에도 트리거한 것은 발동한다(FAQ 2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_LIFEBURST)
  e1:SetRange(LOCATION_SZONE)
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_DRAW)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCondition(function(e,tp,eg,ep) return ep==tp and Duel.GetPhase()==PHASE_ATTACK end)
  -- 발동할 때까지 뽑은 장수(FAQ 6). 업·다운은 모두 한 가지로(FAQ 3)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,0,Duel.GetAttackDrawCount(tp),nil)
  end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()==0 then return end
    local up=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0
    for tc in g:Iter() do
      if up then Duel.Up(tc) else Duel.Down(tc) end
    end
  end)
  c:RegisterEffect(e2)
end
