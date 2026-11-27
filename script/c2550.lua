-- WX12-024 コードハート　†Ｃ・Ｃ・Ｍ†
-- 【常】：このシグニがバニッシュされる場合、代わりにあなたの他の＜電機＞のシグニ１体をバニッシュしてもよい。
-- 【常】：あなたが使用する青と黒のスペルの使用コストは《無×1》減る。
-- 【起】手札から青の＜電機＞のシグニ１枚と黒の＜電機＞のシグニ１枚を捨てる：対戦相手のシグニ１体を対象とし、それをバニッシュする。対戦相手は手札を１枚捨てる。
-- ライフバースト：あなたのデッキの上からカードを５枚公開する。その中から青のカード１枚までと黒のカード１枚までを手札に加え、残りをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  -- 【常】 「代わりに他の＜電機＞をバニッシュ」는 아직(근사 없음)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_REDUCE_COST)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(1,0)
  e1:SetTarget(function(e,x) return x:IsType(TYPE_SPELL) and (x:IsColor(COLOR_BLUE) or x:IsColor(COLOR_BLACK)) end)
  e1:SetEnaCost("{C}")
  e1:SetValue(1)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local u=Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_DENKI)) end)(x) and x:IsColor(COLOR_BLUE) end,tp,LOCATION_HAND,0,nil)
    local b=Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_DENKI)) end)(x) and x:IsColor(COLOR_BLACK) end,tp,LOCATION_HAND,0,nil)
    if chk==0 then return u:GetCount()>0 and b:GetCount()>0 end
    local g=Duel.SelectCards(tp,u,1,1)
    g:Merge(Duel.SelectCards(tp,b:Filter(function(x) return not g:IsContains(x) end,nil),1,1))
    Duel.SendToTrash(g,REASON_COST+REASON_DISCARD)
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
    aux.Discard(1-tp,1)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,5))
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    for _,col in ipairs({COLOR_BLUE,COLOR_BLACK}) do
      local x=Duel.SelectCards(tp,g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) and c:IsColor(col) end,nil),0,1)
      if x:GetCount()>0 then Duel.SendToHand(x) end
    end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e3)
end
