-- WXK10-044 コードメイズ　ドワール
-- 【自】：対戦相手のシグニ１体が【ゲート】があるシグニゾーンに出たとき、対戦相手は手札を１枚デッキの一番下に置く。
-- 【出】《青》手札から＜迷宮＞のシグニを１枚捨てる：この方法で捨てたシグニのレベル以下の対戦相手のシグニ１体を対象とし、それをデッキの一番上に置く。
-- ライフバースト：対戦相手のレベル３以下のシグニ１体を対象とし、それをデッキの一番上に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x and x:GetControler()~=tp and Duel.HasGate(x:GetZone()) end)
  e1:SetOperation(function(e,tp,eg)
    local h=Duel.GetMatchingGroup(nil,1-tp,LOCATION_HAND,0,nil)
    if h:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectCards(1-tp,h,1,1),false) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{U}")
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_MEIKYU) end,tp,LOCATION_HAND,0,nil)
    if chk==0 then return g:GetCount()>0 end
    local x=Duel.SelectCards(tp,g,1,1):GetFirst()
    e:SetLabel(x:GetLevel())
    Duel.SendToTrash(x,REASON_COST+REASON_DISCARD)
  end)
  e2:SetOperation(function(e,tp,eg)
    local lv=e:GetLabel()
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=lv end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.SendToDeckPosition(tc,1) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToDeckPosition(tc,1)
    end
  end)
  c:RegisterEffect(e9)
end
