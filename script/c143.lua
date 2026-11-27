-- WX17-Re02 幻竜　アパト
-- 【常】：あなたのトラッシュに＜龍獣＞のシグニが５枚以上あるかぎり、このシグニの基本パワーは12000になる。
-- 【出】：パワーが「あなたのトラッシュにある＜龍獣＞のシグニの枚数×1000」以下の対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- 【起】《ダウン》手札から＜龍獣＞のシグニを１枚捨てる：あなたのデッキから《幻竜　アパト》以外の＜龍獣＞のシグニ１枚を探して場に出し、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,12000,function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end,e:GetHandlerPlayer(),LOCATION_TRASH,0,nil):GetCount()>=5 end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=1000*Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end,tp,LOCATION_TRASH,0,nil):GetCount() end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsUp() and Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end,tp,LOCATION_HAND,0,nil):GetCount()>0 end
    Duel.Down(e:GetHandler(),REASON_COST)
    Duel.SendToTrash(Duel.SelectDiscard(tp,1,1,function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end),REASON_COST+REASON_DISCARD)
  end)
  e2:SetOperation(function(e,tp)
    local x=aux.Search(tp,function(c) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end)(c) and not c:IsCardName(id) end,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e2)
end
