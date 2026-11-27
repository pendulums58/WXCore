-- WX22-008 ミルルン・モル
-- 【出】：あなたのデッキの上からカードを４枚公開する。その中からそれぞれ名前の異なるように好きな枚数の＜原子＞のシグニを選び手札に加え、残りをトラッシュに置く。
-- 【起】《ターン２回》《スペルカットインアイコン》《青×0》：コストの合計が１以下のスペル１つを対象とし、それの効果を打ち消す。そうした場合、カードを１枚引く。
-- 【起】《アタックフェイズアイコン》エクシード１：対戦相手のシグニ１体を対象とし、手札から＜原子＞のシグニを１枚捨てる。そうした場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,4))
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    Duel.SetSelectCheck(function(sg) local seen={} for x in sg:Iter() do if seen[x:GetCode()] then return false end seen[x:GetCode()]=true end return true end)
    local x=Duel.SelectCards(tp,g:Filter(function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end,nil),0,4)
    if x:GetCount()>0 then Duel.SendToHand(x) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(2)
  e2:SetTiming(TIMING_CUTIN)
  e2:SetOperation(function(e,tp)
    local sp=Duel.GetCutinSpell()
    if sp and sp:GetCostTotal()<=1 then Duel.NegateSpell() Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetExceedCost(1)
  e3:SetTiming(TIMING_ATTACK)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end,tp,LOCATION_HAND,0,nil)
    if g:GetCount()==0 or Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT+REASON_DISCARD)==0 then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e3)
end
