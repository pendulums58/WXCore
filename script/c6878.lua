-- WXK09-004 ストーリー・テラー
-- あなたのセンタールリグが＜アルフォウ＞の場合、このアーツの使用コストは《黒×2》減る。
-- 以下の３つから１つを選ぶ。
-- ①あなたのトラッシュにカードが３０枚以上ある場合、対戦相手のすべてのシグニをバニッシュする。
-- ②あなたのライフクロスが０枚の場合、あなたのトラッシュから対象のシグニ１枚を手札に加え対象のシグニ１枚を場に出す。
-- ③あなたのトラッシュからシグニ６枚を対象とし、あなたの手札が０枚の場合、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) end)
  e1:SetOperation(function(e,tp,eg)
    local m=e:GetLabel()
    if m==0 then
      if Duel.GetMatchingGroup(nil,tp,LOCATION_TRASH,0,nil):GetCount()>=30 then
        local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
        if g:GetCount()>0 then Duel.Banish(g) end
      end
    elseif m==1 then
      if Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()>0 then return end
      local a=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
      local b=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x~=a end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
      if a then Duel.SendToHand(a) end
      if b then Duel.PutOnField(b,tp) end
    else
      local g=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,6,6,nil)
      if g:GetCount()>0 and Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()==0 then Duel.SendToHand(g) end
    end
  end)
  c:RegisterEffect(e1)
  aux.SetCostBy(e1,function(e,tp,base) if (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_ALFOU) end)() then return Duel.ReduceCost(base,"{B}{B}",1) end return base end)
end
