-- WX21-028 美しき豊穣　#フレイン#
-- 【出】：あなたのデッキの上からカードを２枚公開する。その中からすべての＜天使＞のシグニをエナゾーンに置き、残りを好きな順番でデッキの一番下に置く。
-- 【起】《ターン１回》《緑×0》：対戦相手の、シグニ１体とエナゾーンにあるカード１枚とトラッシュにあるカード１枚を対象とし、あなたのエナゾーンから赤と青と緑の＜天使＞のシグニを１枚ずつデッキに加えてシャッフルする。そうした場合、それらをシャッフルしてデッキの一番下に置く。
-- ライフバースト：あなたのデッキの上からカードを４枚公開する。その中から共通する色を持たない＜天使＞のシグニを２枚まで手札に加え、残りをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,2))
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local a=g:Filter(function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,nil)
    if a:GetCount()>0 then Duel.SendToEna(a) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
    Duel.SelectTarget(tp,nil,tp,0,LOCATION_ENA,1,1,nil)
    Duel.SelectTarget(tp,nil,tp,0,LOCATION_TRASH,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local en=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,tp,LOCATION_ENA,0,nil)
    local pick=Group.CreateGroup()
    for _,col in ipairs({COLOR_RED,COLOR_BLUE,COLOR_GREEN}) do
      local x=Duel.SelectCards(tp,en:Filter(function(c) return c:IsColor(col) and not pick:IsContains(c) end,nil),1,1):GetFirst()
      if not x then return end
      pick:AddCard(x)
    end
    Duel.SendToDeckShuffle(pick,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToDeckBottom(g,true) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,4))
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    Duel.SetSelectCheck(function(sg) local m=0 for x in sg:Iter() do if x:GetColor()&m~=0 then return false end m=m|x:GetColor() end return true end)
    local x=Duel.SelectCards(tp,g:Filter(function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,nil),0,2)
    if x:GetCount()>0 then Duel.SendToHand(x) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e3)
end
