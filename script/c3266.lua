-- WX22-046 水仙の柘榴　†ペルセポネ†
-- 【起】《ダウン》手札から＜天使＞のシグニを１枚捨てる：あなたのトラッシュから、この方法で捨てたシグニのレベル以下の＜天使＞のシグニ１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,tp,LOCATION_HAND,0,nil)
    if chk==0 then return e:GetHandler():IsUp() and g:GetCount()>0 end
    Duel.Down(e:GetHandler(),REASON_COST)
    local x=Duel.SelectCards(tp,g,1,1):GetFirst()
    e:SetLabel(x:GetLevel())
    Duel.SendToTrash(x,REASON_COST+REASON_DISCARD)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local lv=e:GetLabel()
    Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end)(x) and x:GetLevel()<=lv end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
end
