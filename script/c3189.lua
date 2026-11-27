-- WX21-026 羅原姫　Ｚｒ
-- 【起】《ターン１回》手札から＜原子＞のシグニを１枚捨てる：カードを２枚引く。
-- 【起】《アタックフェイズアイコン》《青》：対戦相手のシグニ１体を対象とし、このシグニとそれをバニッシュする。
-- 【起】《アタックフェイズアイコン》《青》《無》：あなたのトラッシュからそれぞれ名前の異なる無色ではないシグニ１０枚をデッキに加えてシャッフルする。そうした場合、このシグニをトラッシュから場に出す。
-- ライフバースト：カードを１枚引く。その後、あなたの手札が４枚以下の場合、カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCost(aux.DiscardCost(1,function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end))
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,2)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetEnaCost("{U}")
  e2:SetTiming(TIMING_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    local g=Group.CreateGroup(e:GetHandler())
    if tc and tc:IsRelateToEffect(e) then g:AddCard(tc) end
    Duel.Banish(g)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_TRASH)
  e3:SetEnaCost("{U}{C}")
  e3:SetTiming(TIMING_ATTACK)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetColor()~=0 and x~=e:GetHandler() end,tp,LOCATION_TRASH,0,nil)
    Duel.SetSelectCheck(function(sg) if sg:GetCount()==0 then return true end local seen={} for x in sg:Iter() do if seen[x:GetCode()] then return false end seen[x:GetCode()]=true end return sg:GetCount()==10 end)
    local pick=Duel.SelectCards(tp,g,0,10)
    if pick:GetCount()<10 then return end
    Duel.SendToDeckShuffle(pick,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_TRASH) then Duel.PutOnField(h,tp) end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()<=4 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e4)
end
