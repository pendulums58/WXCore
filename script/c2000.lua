-- WX04-002 遊月・四戎
-- 【常】：対戦相手のエナゾーンにあるカードが４枚以下であるかぎり、あなたのシグニのパワーを＋2000する。
-- 【起】あなたのエナゾーンからすべての赤のカードをトラッシュに置く：この方法で赤のカードが３枚以上トラッシュに置かれた場合、対戦相手のライフクロス１枚をクラッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return (Card.IsSigni)(x) end)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),0,LOCATION_ENA,nil):GetCount()<=4 end)
  e1:SetValue(2000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  -- 【マルチエナ】는 적이 아니다(FAQ 3)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local g=Duel.GetMatchingGroup(function(x) return x:IsColor(COLOR_RED) end,tp,LOCATION_ENA,0,nil)
    e:SetLabel(g:GetCount()>0 and Duel.SendToTrash(g,REASON_COST) or 0)
  end)
  e2:SetOperation(function(e,tp)
    if e:GetLabel()>=3 then Duel.Crush(1-tp,1) end
  end)
  c:RegisterEffect(e2)
end
