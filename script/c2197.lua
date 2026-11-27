-- WX07-027 羅原　Ｈ
-- 《クロスアイコン》《羅原　O》の左
-- 【クロス常】：このシグニの基本パワーは15000になる。
-- 【起】《青》《青》《青》：シグニ１体を対象とし、それをバニッシュする。この能力の使用コストに含まれる《青》を支払う際、代わりに手札から＜原子＞のシグニを１枚捨ててもよい。
-- 【クロス自】：このシグニが《ヘブン》したとき、あなたのトラッシュから＜原子＞のシグニ１枚を手札に加える。
-- ライフバースト：あなたの＜原子＞のシグニ１体につきシグニを１体まで対象とし、それらをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,2209,CROSS_LEFT)
  -- [の間] 【クロス常】
  aux.BasePower(c,15000,function(e) return e:GetHandler():IsCross() end)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_SZONE)
  -- 《青》 하나 대신 <원자> 시그니 1장을 버려도 된다(FAQ 2)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local h=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end,tp,LOCATION_HAND,0,nil)
    if chk==0 then
      for k=0,math.min(3,h:GetCount()) do if Duel.CanPayEna(tp,string.rep("{U}",3-k)) then return true end end
      return false
    end
    Duel.SetSelectCheck(function(g) return Duel.CanPayEna(tp,string.rep("{U}",3-g:GetCount())) end)
    local d=Duel.SelectCards(tp,h,0,3)
    if d:GetCount()>0 then Duel.SendToTrash(d,REASON_COST+REASON_DISCARD) end
    local rest=3-d:GetCount()
    if rest>0 then Duel.SendToTrash(Duel.SelectEnaCost(tp,string.rep("{U}",rest)),REASON_COST) end
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetCode(EVENT_HEAVEN)
  e3:SetRange(LOCATION_SZONE)
  e3:SetOperation(function(e,tp)
    local x=Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if x then Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local n=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end,tp,LOCATION_SZONE,0,nil):GetCount()
    if n>0 then Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,0,n,nil) end
  end)
  e4:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e4)
end
