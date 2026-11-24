-- WD23-033-A 超罠　ボーウケアミ
-- 【出】《青》《青》：あなたのデッキからカードを３枚まで探して【トラップ】としてあなたのシグニゾーンに設置し、デッキをシャッフルする。
-- 【起】《アタックフェイズアイコン》＜トリック＞のシグニ１体を場からトラッシュに置く：カードを１枚引く。
-- 【トラップアイコン】：対戦相手のシグニ１体を対象とし、手札から＜トリック＞のシグニを２枚捨ててもよい。そうした場合、それをバニッシュする。
-- ライフバースト：あなたのトラッシュから《トラップアイコン》を持つシグニを２枚まで対象とし、それらを手札に加える。
local s,id=GetID()
s.trick=aux.ClassFilter(0,RACE_TRICK)  -- ＜トリック＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{U}{U}")
  e1:SetOperation(function(e,tp)
    for tc in aux.Search(tp,nil,3):Iter() do Duel.SetTrap(tc,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetTiming(TIMING_ATTACK)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.trick,tp,LOCATION_SZONE,0,nil)
    if chk==0 then return g:GetCount()>0 end
    Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_COST)
  end)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_TRAP)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc,g=Duel.GetFirstTarget(),Duel.GetMatchingGroup(s.trick,tp,LOCATION_HAND,0,nil)
    if not tc or g:GetCount()<2 or not Duel.SelectYesNo(tp) then return end
    if Duel.SendToTrash(Duel.SelectDiscard(tp,2,2,s.trick),REASON_EFFECT+REASON_DISCARD)==2 and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:HasTrapIcon() end,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e4:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e4)
end
