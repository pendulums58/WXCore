-- WDK15-001 ナナシ　其ノ四ノ報
-- 【自】《ターン１回》：《ライズアイコン_黒》を持つあなたのシグニ１体が場に出たとき、あなたのトラッシュからシグニ１枚を対象とし、それをそのシグニの下に置く。
-- 【出】：あなたのトラッシュから《ライズアイコン_黒》を持つシグニ１枚と＜ウェポン＞のシグニ１枚を対象とし、それらを手札に加える。
-- 【起】《ゲーム１回》《メインフェイズアイコン》《アタックフェイズアイコン》ブラインド《コインアイコン》：あなたのトラッシュから対象のシグニを２枚まで、対象のあなたの＜ウェポン＞のシグニ２体までの下に置く。下にカードがあるあなたのシグニ１体につきカードを１枚引く。
local s,id=GetID()
s.weapon=aux.ClassFilter(0,RACE_WEAPON)  -- ＜ウェポン＞のシグニ
s.rise=function(x) return x:IsSigni() and x:HasRiseIcon() and x:IsColor(COLOR_BLACK) end  -- 《ライズアイコン_黒》を持つシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()==tp and s.rise(x) end)
  -- 라이즈 조건은 이 능력으로 놓을 카드 없이 채워야 한다(FAQ 1). 강제(FAQ 2)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local x,tc=eg:GetFirst(),Duel.GetFirstTarget()
    if x:IsLocation(LOCATION_SZONE) and tc and tc:IsRelateToEffect(e) then Duel.PutUnder(x,tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  -- 한쪽만 있으면 그것만(FAQ 3)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local a=Duel.SelectTarget(tp,s.rise,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    Duel.SelectTarget(tp,s.weapon,tp,LOCATION_TRASH,0,1,1,a)
  end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e3:SetCountLimit(1,true)
  e3:SetCoinCost(1)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,0,2,nil)
    Duel.SelectTarget(tp,s.weapon,tp,LOCATION_SZONE,0,0,2,nil)
  end)
  -- 2장을 한 체 아래에 둘 다 놓아도 된다(FAQ 4)
  e3:SetOperation(function(e,tp)
    local cards,hosts=Group.CreateGroup(),Group.CreateGroup()
    for x in Duel.GetTargets():Iter() do
      if x:IsRelateToEffect(e) then
        if x:IsLocation(LOCATION_TRASH) then cards:AddCard(x) else hosts:AddCard(x) end
      end
    end
    if hosts:GetCount()>0 then
      for x in cards:Iter() do
        local h=hosts:GetCount()==1 and hosts:GetFirst() or Duel.SelectCards(tp,hosts,1,1):GetFirst()
        Duel.PutUnder(h,x)
      end
    end
    local n=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetUnderGroup():GetCount()>0 end,tp,LOCATION_SZONE,0,nil):GetCount()
    if n>0 then Duel.Draw(tp,n) end
  end)
  c:RegisterEffect(e3)
end
