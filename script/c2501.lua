-- WX11-052 サーバント　Ｚ
-- 【常】：【マルチエナ】
-- 【出】《無》《無》《無》：あなたのデッキから《サーバント　Ｘ》１枚と《サーバント　Ｙ》１枚を探して場に出し、デッキをシャッフルする。
-- 【起】エナゾーンから名前の異なる＜精元＞のシグニ８枚をトラッシュに置く：対戦相手の手札とエナゾーンにあるすべてのカードをゲームから除外する。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_MULTI_ENA)
  e1:SetRange(LOCATION_ENA)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{C}{C}{C}")
  e2:SetOperation(function(e,tp)
    for _,cid in ipairs({2031,2422}) do
      local x=aux.Search(tp,function(c) return c:IsCardName(cid) end,1):GetFirst()
      if x then Duel.PutOnField(x,tp) end
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_SZONE)
  e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(SYS_SEIGEN,0) end,tp,LOCATION_ENA,0,nil)
    local names,n={},0
    for x in g:Iter() do if not names[x:GetCode()] then names[x:GetCode()]=true n=n+1 end end
    if chk==0 then return n>=8 end
    Duel.SetSelectCheck(function(sg)
      local seen={}
      for x in sg:Iter() do
        if seen[x:GetCode()] then return false end
        seen[x:GetCode()]=true
      end
      return true
    end)
    Duel.SendToTrash(Duel.SelectCards(tp,g,8,8),REASON_COST)
  end)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND+LOCATION_ENA,nil)
    if g:GetCount()>0 then Duel.Exclude(g) end
  end)
  c:RegisterEffect(e3)
end
