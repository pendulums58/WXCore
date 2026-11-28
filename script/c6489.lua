-- WXK04-033 ＩＣＥ　ＳＴＯＲＭ
-- あなたのトラッシュから対象の＜調理＞のシグニを３枚まで、対象のあなたの＜調理＞のシグニ３体までの【アクセ】にする。ターン終了時、この方法で【アクセ】にしたすべてのカードを場から手札に戻す。
-- （【アクセ】はシグニ１体に１枚までしか付けられない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_CHOURI) end,tp,LOCATION_TRASH,0,0,3,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local put={}
    for x in Duel.GetTargets():Iter() do
      if x:IsRelateToEffect(e) and x:IsLocation(LOCATION_TRASH) then
        local host=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(h) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_CHOURI) end)(h) and Duel.GetMatchingGroup(function(a) return a:GetAcceHost()==h end,tp,LOCATION_ACCE,0,nil):GetCount()==0 end,tp,LOCATION_SZONE,0,nil),0,1):GetFirst()
        if host and Duel.Acce(x,host) then put[#put+1]=x end
      end
    end
    if #put==0 then return end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_TURN_END)
    e1:SetOperation(function()
      local g=Group.CreateGroup()
      for _,x in ipairs(put) do if x:IsLocation(LOCATION_ACCE) then g:AddCard(x) end end
      if g:GetCount()>0 then Duel.SendToHand(g) end
    end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
