-- WX05-044 コードアンチ　マズフェイス
-- 【起】《ダウン》他の＜古代兵器＞のシグニ１体をバニッシュする：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－7000する。
-- 【起】《ダウン》他の＜古代兵器＞のシグニ２体を場からトラッシュに置く：ターン終了時まで、対戦相手のすべてのシグニのパワーを－10000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local h=e:GetHandler()
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KODAIHEIKI)) end,tp,LOCATION_SZONE,0,h)
    if chk==0 then return h:IsUp() and g:GetCount()>0 end
    Duel.Down(h,REASON_COST)
    Duel.Banish(Duel.SelectCards(tp,g,1,1))
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-7000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local h=e:GetHandler()
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KODAIHEIKI)) end,tp,LOCATION_SZONE,0,h)
    if chk==0 then return h:IsUp() and g:GetCount()>=2 end
    Duel.Down(h,REASON_COST)
    Duel.SendToTrash(Duel.SelectCards(tp,g,2,2),REASON_COST)
  end)
  -- [まで] 처리할 때 장에 있는 시그니만
  e2:SetOperation(function(e,tp)
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do aux.AddPower(e,tc,-10000) end
  end)
  c:RegisterEffect(e2)
end
