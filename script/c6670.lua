-- WXK06-055 ブラック・ドラゴン・ウェーブ
-- このスペルの使用コストはあなたのトラッシュにある＜龍獣＞のシグニ５枚につき《黒×1》減る。
-- 以下の３つから１つを選ぶ。
-- ①あなたのトラッシュから＜龍獣＞のシグニを２枚まで対象とし、それらを手札に加える。
-- ②対戦相手のすべてのシグニをバニッシュする。
-- ③対戦相手は自分のエナゾーンにあるカードが６枚になるように、エナゾーンからカードをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==0 then Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_RYUJU) end,tp,LOCATION_TRASH,0,0,2,nil) end
  end)
  e1:SetOperation(function(e,tp,eg)
    local m=e:GetLabel()
    if m==0 then
      local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
      if g:GetCount()>0 then Duel.SendToHand(g) end
    elseif m==1 then
      local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
      if g:GetCount()>0 then Duel.Banish(g) end
    else
      local en=Duel.GetMatchingGroup(nil,1-tp,LOCATION_ENA,0,nil)
      local k=en:GetCount()-6
      if k>0 then Duel.SendToTrash(Duel.SelectCards(1-tp,en,k,k),REASON_EFFECT) end
    end
  end)
  c:RegisterEffect(e1)
  aux.SetCostBy(e1,function(e,tp,base) return Duel.ReduceCost(base,"{B}",math.floor(Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_RYUJU) end,tp,LOCATION_TRASH,0,nil):GetCount()/5)) end)
end
