-- WX05-013 侵犯されし神判　アン・フィフス
-- 【グロウ】あなたのセンタールリグがカード名に《アン》を含む
-- 【出】：あなたのトラッシュから＜美巧＞のシグニを３枚まで対象とし、それらを手札に加える。
-- 【起】エクシード２：対戦相手のアタックしているシグニ１体を対象とし、それのアタックを一度無効にする。この能力は対戦相手のシグニ１体がアタックしたときにしか使用できない。
-- 【起】エクシード３：あなたの手札を公開する。この方法で＜美巧＞のシグニが８種類以上公開された場合、対戦相手のすべてのシグニを手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  -- 【グロウ】 센터 루리그 이름에 《アン》(aux.NameHas)
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetCode(EFFECT_GROW_PROC)
  e0:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
      local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
      return lc and aux.NameHas(lc,"アン")
    end
  end)
  c:RegisterEffect(e0)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end,tp,LOCATION_TRASH,0,0,3,nil)
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e1)
  -- 상대 시그니가 어택했을 때만 쓴다. 그 어택에 맞춘 선택형 【自】로 처리한다(FAQ 2)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ATTACK)
  e2:SetRange(LOCATION_LRIG)
  e2:SetExceedCost(2)
  e2:SetAbilityType(ABILITY_IGNITION)
  e2:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:IsSigni() and x:GetControler()~=tp end)
  e2:SetOperation(function(e,tp)
    Duel.NegateAttack()
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetRange(LOCATION_LRIG)
  e3:SetExceedCost(3)
  e3:SetOperation(function(e,tp)
    local h=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    if h:GetCount()==0 then return end
    Duel.RevealCards(h)
    local seen,n={},0
    for x in h:Filter(function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end,nil):Iter() do
      if not seen[x:GetCode()] then
        seen[x:GetCode()]=true
        n=n+1
      end
    end
    if n<8 then return end
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e3)
end
