-- WX10-053 集結する守護
-- このスペルの使用コストはあなたの場にあるカード名に《サーバント》を含むシグニ１体につき《無×2》減る。
-- 以下の２つから１つを選ぶ。
-- ①あなたのトラッシュからカード名に《サーバント》を含むシグニを２枚まで対象とし、それらを手札に加える。
-- ②ターン終了時まで、カード名に《サーバント》を含むあなたのすべてのシグニのパワーを＋5000し、それらは【ランサー】を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) return Duel.ReduceCost(base,"{C}",2*Duel.GetMatchingGroup(function(x) return x:IsSigni() and aux.NameHas(x,"サーバント") end,tp,LOCATION_SZONE,0,nil):GetCount()) end)
  e1:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e1:SetOperation(function(e,tp)
    local sv=function(x) return x:IsSigni() and aux.NameHas(x,"サーバント") end
    if e:GetLabel()==0 then
      local g=Duel.SelectTarget(tp,sv,tp,LOCATION_TRASH,0,0,2,nil)
      if g:GetCount()>0 then Duel.SendToHand(g) end
      return
    end
    -- [まで] 처리할 때 장에 있는 시그니
    for tc in Duel.GetMatchingGroup(sv,tp,LOCATION_SZONE,0,nil):Iter() do
      aux.AddPower(e,tc,5000)
      aux.GrantKeyword(e,tc,EFFECT_LANCER)
    end
  end)
  c:RegisterEffect(e1)
end
