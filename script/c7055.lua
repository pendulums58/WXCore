-- WXK10-081 幻水　ライムラス
-- 【常】：このシグニはパワーが7000以上であるかぎり、【ランサー】を得る。
-- （【ランサー】を持つシグニがバトルでシグニをバニッシュしたとき、対戦相手のライフクロスを１枚クラッシュする）
-- 【出】：あなたの＜水獣＞のシグニ１体を対象とし、あなたの手札からそれぞれ名前の異なる＜水獣＞のシグニを好きな枚数公開する。ターン終了時まで、それのパワーをこの方法で公開したカード１枚につき＋1000する。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_LANCER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():GetPower()>=7000 end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_SUIJU) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local h=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_SUIJU) end,tp,LOCATION_HAND,0,nil)
      local seen,n=Group.CreateGroup(),{}
      for x in h:Iter() do if not n[x:GetCode()] then n[x:GetCode()]=true seen:AddCard(x) end end
      local pick=seen:GetCount()>0 and Duel.SelectCards(tp,seen,0,seen:GetCount()) or Group.CreateGroup()
      if pick:GetCount()>0 then Duel.RevealCards(pick) aux.AddPower(e,tc,1000*pick:GetCount()) end
    end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e9)
end
