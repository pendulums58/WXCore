-- WX14-025 撃弩炎　フレイスロ大将
-- 【自】：あなたのターンの間、対戦相手のシグニ１体が場に出たとき、そのシグニのパワーが8000以下の場合、それをバニッシュする。
-- 【出】《赤》《赤》《赤》：あなたの場にカード名に《フレイスロ》を含むシグニが３体ある場合、対戦相手のすべてのシグニをバニッシュする。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それをバニッシュする。あなたのトラッシュにカード名に《フレイスロ》を含むシグニが１０枚以上ある場合、対戦相手のライフクロス１枚をクラッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return Duel.GetTurnPlayer()==tp and x:GetControler()~=tp and x:IsSigni() end)
  e1:SetOperation(function(e,tp,eg)
    local x=eg:GetFirst()
    if x:IsLocation(LOCATION_SZONE) and x:GetPower()<=8000 then Duel.Banish(x) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{R}{R}{R}")
  e2:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(function(x) return x:IsSigni() and aux.NameHas(x,"フレイスロ") end,tp,LOCATION_SZONE,0,nil):GetCount()>=3 then local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil) if g:GetCount()>0 then Duel.Banish(g) end end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
    if Duel.GetMatchingGroup(function(x) return x:IsSigni() and aux.NameHas(x,"フレイスロ") end,tp,LOCATION_TRASH,0,nil):GetCount()>=10 then Duel.Crush(1-tp,1) end
  end)
  c:RegisterEffect(e3)
end
