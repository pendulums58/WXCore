-- WD14-002 無道の閻魔　ウリス
-- 【常】：あなたの＜悪魔＞のシグニのパワーを＋1000する。
-- 【起】エクシード２：あなたのデッキの上からカードを４枚見る。その中からカード１枚を手札に加え、残りをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x:IsClass(0,RACE_AKUMA) end)
  e1:SetValue(1000)
  c:RegisterEffect(e1)
  -- 1장은 반드시 패에 넣는다(FAQ 1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetExceedCost(2)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,4)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local sg=Duel.SelectCards(tp,g,1,1)
    Duel.SendToHand(sg)
    Duel.SendToTrash(g:Filter(function(x) return not sg:IsContains(x) end,nil),REASON_EFFECT)
  end)
  c:RegisterEffect(e2)
end
