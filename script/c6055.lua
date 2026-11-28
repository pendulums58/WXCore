-- WXEX1-21 誘蘭の鍵主　ウムル＝フィーラ
-- 【出】：あなたのデッキの上からカードを５枚トラッシュに置く。カードを２枚引く。
-- 【起】《ターン１回》《黒×0》：あなたのシグニ１体をバニッシュする。そうした場合、あなたのデッキの上からカードを５枚トラッシュに置く。
-- 【起】《メインフェイズアイコン》《アタックフェイズアイコン》《コインアイコン》：対戦相手のシグニ１体を対象とし、あなたのトラッシュから＜古代兵器＞のシグニ１０枚をデッキに加えてシャッフルする。そうした場合、ターン終了時まで、それのパワーを－20000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,5)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    Duel.Draw(tp,2)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetOperation(function(e,tp)
    local tc=Duel.SelectCards(tp,Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil),1,1):GetFirst()
    if tc and Duel.Banish(tc)>0 then
      local g=Duel.GetDecktopGroup(tp,5)
      if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e3:SetCoinCost(1)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local pool=Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_KODAIHEIKI),tp,LOCATION_TRASH,0,nil)
    if pool:GetCount()<10 then return end
    local g=Duel.SelectCards(tp,pool,10,10)
    if g:GetCount()==10 then
      Duel.SendToDeckShuffle(g,tp)
      local tc=Duel.GetFirstTarget()
      if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-20000) end
    end
  end)
  c:RegisterEffect(e3)
end
