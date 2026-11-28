-- WXEX1-22 ミュウ＝フォーゼ
-- 【起】《ターン１回》《黒×0》：以下の３つから対戦相手の場にある【チャーム】１枚につき１つまで選ぶ。
-- ①カードを１枚引く。
-- ②【エナチャージ１】
-- ③対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－8000する。
-- 【起】《メインフェイズアイコン》《アタックフェイズアイコン》《コインアイコン》：対戦相手のトラッシュから対象のカードを３枚まで、対象の対戦相手のシグニ３体までの【チャーム】にする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(1)
  e1:SetDeclare(function(e,tp)
    local n=0
    for x in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do
      if x:GetCharm() then n=n+1 end
    end
    if n>3 then n=3 end
    local mask=0
    if n>0 then
      for _,m in ipairs(Duel.SelectModes(tp,0,n,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) do
        mask=mask|(1<<m)
      end
    end
    e:SetLabel(mask)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if (e:GetLabel()&4)~=0 then Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp)
    local mask=e:GetLabel()
    if (mask&1)~=0 then Duel.Draw(tp,1) end
    if (mask&2)~=0 then Duel.EnaCharge(tp,1) end
    if (mask&4)~=0 then
      local tc=Duel.GetFirstTarget()
      if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-8000) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e2:SetCoinCost(1)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local cg=Duel.SelectTarget(tp,nil,tp,0,LOCATION_TRASH,0,3,nil)
    if cg:GetCount()>0 then
      Duel.SelectTarget(tp,function(x) return x:IsSigni() and not x:GetCharm() end,tp,0,LOCATION_SZONE,0,cg:GetCount(),nil)
    end
  end)
  e2:SetOperation(function(e,tp)
    local tg=Duel.GetTargets():Filter(Card.IsRelateToEffect,nil,e)
    local cards,hosts={},{}
    for x in tg:Iter() do
      if x:IsLocation(LOCATION_TRASH) then cards[#cards+1]=x
      elseif x:IsLocation(LOCATION_SZONE) then hosts[#hosts+1]=x end
    end
    for i=1,math.min(#cards,#hosts) do Duel.Charm(cards[i],hosts[i]) end
  end)
  c:RegisterEffect(e2)
end
