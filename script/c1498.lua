-- WX20-049 似之遊　†オキクドール†
-- 【自】：このシグニがアタックしたとき、《黒》を支払ってもよい。そうした場合、このシグニを場からトラッシュに置き、あなたのデッキからカード名に《ニホニンギョ》を含むシグニを１枚探して場に出し、デッキをシャッフルする。
-- 【出】：対戦相手のシグニ１体を対象とし、あなたのトラッシュにカード名に《ニホニンギョ》を含むカードがある場合、ターン終了時まで、それの基本パワーを4000にする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    if Duel.CanPayEna(tp,"{B}") and Duel.SelectYesNo(tp) then
      Duel.SendToTrash(Duel.SelectEnaCost(tp,"{B}"),REASON_COST)
      local h=e:GetHandler()
      if Duel.SendToTrash(h,REASON_EFFECT)==0 then return end
      local x=aux.Search(tp,function(x) return x:IsSigni() and aux.NameHas(x,"ニホニンギョ") end,1):GetFirst()
      if x then Duel.PutOnField(x,tp) end
      aux.ShuffleDeck(tp)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.GetMatchingGroup(function(x) return aux.NameHas(x,"ニホニンギョ") end,tp,LOCATION_TRASH,0,nil):GetCount()>0 then
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SET_BASE_POWER)
    e1:SetValue(4000)
    e1:SetReset(RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
    end
  end)
  c:RegisterEffect(e2)
end
