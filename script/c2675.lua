-- WX14-009 炎・花代・伍
-- 【常】：このカードにグロウするためのコストは、あなたのトラッシュにあるカード名に《フレイスロ》を含むカード７枚につき《赤×1》減る。
-- 【自】：あなたのカード名に《フレイスロ》を含むシグニ１体が場を離れたとき、あなたの手札からそのシグニより低いレベルを持つ、カード名に《フレイスロ》を含むシグニ１枚をダウン状態で場に出してもよい。
-- 【起】《ターン２回》エクシード１：あなたのトラッシュからカード名に《フレイスロ》を含むシグニ１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 트래시의 《フレイスロ》 7장당 《赤》×1 줄어든다
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetCode(EFFECT_GROW_PROC)
  e0:SetMinCost(function(e,tp,base) return Duel.ReduceCost(base,"{R}",math.floor(Duel.GetMatchingGroup(function(x) return aux.NameHas(x,"フレイスロ") end,tp,LOCATION_TRASH,0,nil):GetCount()/7)) end)
  e0:SetDeclare(function(e,tp) Duel.SetUseCost(Duel.ReduceCost(Duel.GetUseCost(),"{R}",math.floor(Duel.GetMatchingGroup(function(x) return aux.NameHas(x,"フレイスロ") end,tp,LOCATION_TRASH,0,nil):GetCount()/7))) end)
  c:RegisterEffect(e0)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_LEAVE_FIELD)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetOwner()==tp and (function(x) return x:IsSigni() and aux.NameHas(x,"フレイスロ") end)(x) end)
  e1:SetOperation(function(e,tp,eg)
    local lv=eg:GetFirst():GetLevel()
    local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(c) return (function(x) return x:IsSigni() and aux.NameHas(x,"フレイスロ") end)(c) and c:GetLevel()<lv end,tp,LOCATION_HAND,0,nil),0,1):GetFirst()
    if x then Duel.PutOnField(x,tp,false,true) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(2)
  e2:SetExceedCost(1)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and aux.NameHas(x,"フレイスロ") end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e2)
end
