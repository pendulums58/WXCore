-- WX04-003 ミルルン・ヨクト
-- 【出】：対戦相手の手札を見て、その中からスペル１枚を、あなたの手札にあるかのようにコストを支払わずに限定条件を無視して使用してもよい。
-- 【起】《青》手札からスペル１枚と＜原子＞のシグニ１枚を捨てる：対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- 【起】《スペルカットインアイコン》《青》《青》：スペル１つを対象とし、それの効果を打ち消す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  -- 쓰지 않은 스펠은 패에 남는다(FAQ 2). 쓰면 상대 트래시로(FAQ 1)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local sp=Duel.SelectCards(tp,g:Filter(function(x) return x:IsType(TYPE_SPELL) end,nil),0,1):GetFirst()
    if sp then Duel.UseFree(sp,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetEnaCost("{U}")
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local sp=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_SPELL) end,tp,LOCATION_HAND,0,nil)
    local at=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end,tp,LOCATION_HAND,0,nil)
    if chk==0 then return sp:GetCount()>0 and at:GetCount()>0 end
    local g=Duel.SelectCards(tp,sp,1,1)
    g:AddCard(Duel.SelectCards(tp,at,1,1):GetFirst())
    Duel.SendToTrash(g,REASON_COST+REASON_DISCARD)
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(aux.BanishOp)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetTiming(TIMING_CUTIN)
  e3:SetEnaCost("{U}{U}")
  e3:SetOperation(function(e,tp)
    Duel.NegateSpell()
  end)
  c:RegisterEffect(e3)
end
