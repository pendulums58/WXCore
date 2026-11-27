-- WX20-050 大拳　ニャックル
-- 【自】：このシグニがアタックしたとき、あなたのカード名に《ニャローブ》を含むシグニ１体をバニッシュしてもよい。そうした場合、このシグニをアップする。
-- 【自】：対戦相手のターンの間、このシグニが場を離れたとき、あなたのデッキからカード名に《ニャローブ》を含むシグニ１枚を探して公開し手札に加えるか場に出し、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and aux.NameHas(x,"ニャローブ") end,tp,LOCATION_SZONE,0,nil)
    if g:GetCount()==0 or not Duel.SelectYesNo(tp) or Duel.Banish(Duel.SelectCards(tp,g,1,1))==0 then return end
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then Duel.Up(h) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_LEAVE_FIELD)
  e2:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  e2:SetOperation(function(e,tp)
    local x=aux.Search(tp,function(x) return x:IsSigni() and aux.NameHas(x,"ニャローブ") end,1):GetFirst()
    if x then
      Duel.RevealCards(Group.CreateGroup(x))
      if Duel.SelectYesNo(tp) then Duel.PutOnField(x,tp) else Duel.SendToHand(x) end
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e2)
end
