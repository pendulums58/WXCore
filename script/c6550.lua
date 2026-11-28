-- WXK05-003 血晶照射
-- 以下の４つから２つまで選ぶ。あなたのセンタールリグが＜ＬｏＶ＞の場合、代わりに３つまで選ぶ。
-- ①あなたは手札をすべて捨て、カードを４枚引く。
-- ②対戦相手のパワー7000以下のシグニ１体を対象とし、それをバニッシュする。
-- ③対戦相手のパワー12000以下のシグニ１体を対象とし、それをバニッシュする。手札を１枚捨てる。
-- ④対戦相手のシグニ１体を対象とし、手札からレベル４のシグニを１枚捨てる。そうした場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,(function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_LOV) end)() and 3 or 2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local m=e:GetLabel()
    if m&2~=0 then Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=7000 end,tp,0,LOCATION_SZONE,1,1,nil) end
    if m&4~=0 then Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=12000 end,tp,0,LOCATION_SZONE,1,1,nil) end
    if m&8~=0 then Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp,eg)
    local m=e:GetLabel()
    local t={}
    for x in Duel.GetTargets():Iter() do t[#t+1]=x end
    local k=1
    local function nx() local x=t[k] k=k+1 return x and x:IsRelateToEffect(e) and x or nil end
    if m&1~=0 then
      local h=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
      if h:GetCount()>0 then Duel.SendToTrash(h,REASON_EFFECT+REASON_DISCARD) end
      Duel.Draw(tp,4)
    end
    if m&2~=0 then local x=nx() if x and x:GetPower()<=7000 then Duel.Banish(x) end end
    if m&4~=0 then local x=nx() if x and x:GetPower()<=12000 then Duel.Banish(x) end aux.Discard(tp,1) end
    if m&8~=0 then
      local x=nx()
      local h=Duel.GetMatchingGroup(function(y) return y:IsSigni() and y:GetLevel()==4 end,tp,LOCATION_HAND,0,nil)
      if x and h:GetCount()>0 and Duel.SendToTrash(Duel.SelectCards(tp,h,1,1),REASON_EFFECT+REASON_DISCARD)>0 then Duel.Banish(x) end
    end
  end)
  c:RegisterEffect(e1)
end
