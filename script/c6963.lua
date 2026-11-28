-- WXK09-090 白雪の童話　ナナコビト
-- 【起】このシグニを場からトラッシュに置く：あなたのトラッシュから《白雪の童話　ナナコビト》以外の＜美巧＞のシグニ１枚を対象とし、あなたのトラッシュから《白雪の童話　ナナコビト》以外のそれぞれ名前の異なる＜美巧＞のシグニ７枚をデッキに加えてシャッフルする。そうした場合、それを場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_SZONE) end
    Duel.SendToTrash(e:GetHandler(),REASON_COST)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_BIKOU) end)(x) and not x:IsCardName(id) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local pool=Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_BIKOU) end)(x) and not x:IsCardName(id) and x~=tc end,tp,LOCATION_TRASH,0,nil)
      local pick,seen=Group.CreateGroup(),{}
      for i=1,7 do
        local c2=pool:Filter(function(y) return not seen[y:GetCode()] end,nil)
        if c2:GetCount()==0 then return end
        local y=Duel.SelectCards(tp,c2,1,1):GetFirst()
        seen[y:GetCode()]=true
        pick:AddCard(y)
      end
      Duel.SendToDeckShuffle(pick)
      Duel.PutOnField(tc,tp)
    end
  end)
  c:RegisterEffect(e1)
end
