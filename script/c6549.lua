-- WXK05-002 ブリーディング・フォース
-- あなたのセンタールリグが＜イオナ＞の場合、このアーツの使用コストは《白×2》減る。
-- 以下の３つから３つまで選ぶ。選んだ数が２つ以上の場合、このアーツの使用コストは、選んだ数から１を引いた数だけ《白×2》《無×1》増える。
-- ①対戦相手のシグニ１体を対象とし、それを手札に戻す。
-- ②対戦相手のシグニ１体を対象とし、それをトラッシュに置く。手札を２枚捨てる。
-- ③あなたのデッキから白のシグニを２枚まで探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetMinCost(function(e,tp,base) if (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_IONA) end)() then return Duel.ReduceCost(base,"{W}{W}",1) end return base end)
  e1:SetDeclare(function(e,tp)
    local base=Duel.GetUseCost()
    if (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_IONA) end)() then base=Duel.ReduceCost(base,"{W}{W}",1) end
    -- 낼 수 있는 만큼만 고를 수 있다
    local mx=1
    while mx<3 and Duel.CanPayEna(tp,base..string.rep("{W}{W}{C}",mx)) do mx=mx+1 end
    local m,n=0,0
    for _,i in ipairs(Duel.SelectModes(tp,1,mx,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) do m=m|(1<<i) n=n+1 end
    e:SetLabel(m)
    Duel.SetUseCost(base..string.rep("{W}{W}{C}",n-1))
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local m=e:GetLabel()
    if m&1~=0 then Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil) end
    if m&2~=0 then Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp,eg)
    local m=e:GetLabel()
    local t={}
    for x in Duel.GetTargets():Iter() do t[#t+1]=x end
    local k=1
    if m&1~=0 then local x=t[k] k=k+1 if x and x:IsRelateToEffect(e) then Duel.SendToHand(x) end end
    if m&2~=0 then local x=t[k] if x and x:IsRelateToEffect(e) and x:IsLocation(LOCATION_SZONE) then Duel.SendToTrash(x,REASON_EFFECT) end aux.Discard(tp,2) end
    if m&4~=0 then aux.SearchToHand(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_WHITE) end,2) end
  end)
  c:RegisterEffect(e1)
end
