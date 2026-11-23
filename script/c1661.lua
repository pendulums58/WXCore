-- WDK08-Y01 爪牙　遊月・肆
-- 【出】：対戦相手のシグニ１体を対象とし、あなたの手札から＜水獣＞のシグニを４枚公開する。そうした場合、カードを１枚引く。
--   この方法でそれぞれレベルの異なるシグニ４枚が公開された場合、追加でそれをエナゾーンに置く。
-- 【起】《ターン１回》《メインフェイズアイコン》《アタックフェイズアイコン》《緑》手札から＜水獣＞のシグニを１枚捨てる：
--   あなたの＜水獣＞のシグニ１体を対象とし、ターン終了時まで、それのパワーをこの方法で捨てたシグニのパワーと同じだけ＋（プラス）する。
local s,id=GetID()
s.suiju=aux.ClassFilter(0,RACE_SUIJU)  -- ＜水獣＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e2:SetCountLimit(1)
  e2:SetEnaCost("{G}")
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetMatchingGroup(s.suiju,tp,LOCATION_HAND,0,nil):GetCount()>=1 end
    local dc=Duel.SelectDiscard(tp,1,1,s.suiju)
    e:SetLabel(dc:GetFirst():GetPower())  -- 패에 있을 때의 파워
    Duel.SendToTrash(dc,REASON_COST+REASON_DISCARD)
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,s.suiju,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,e:GetLabel()) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e2)
end
-- 공개하지 않아도 된다(FAQ 3). 대상이 없어도 공개하고 뽑을 수 있다(FAQ 1)
function s.op(e,tp)
  local sg=aux.RevealFromHand(tp,s.suiju,4)
  if sg:GetCount()~=4 then return end
  Duel.Draw(tp,1)
  local lv={}
  for x in sg:Iter() do
    if lv[x:GetLevel()] then return end
    lv[x:GetLevel()]=true
  end
  -- 바니시가 아니라 에나 존에 놓는다(「バニッシュされない」도 놓을 수 있다. FAQ 2)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then Duel.SendToEna(tc) end
end
