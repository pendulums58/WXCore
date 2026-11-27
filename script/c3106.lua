-- WX20-006 共存共栄
-- あなたの場に＜精羅＞のシグニがある場合、このアーツの使用コストは《緑×2》減る。
-- 以下の２つから１つを選ぶ。
-- ①あなたのデッキから＜精羅＞のシグニを３枚まで探してエナゾーンに置き、デッキをシャッフルする。
-- ②対戦相手のパワー12000以上のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) if Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(SYS_SEIRA,0) end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then return Duel.ReduceCost(base,"{G}",2) end return base end)
  e1:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==0 then
      local g=aux.Search(tp,function(x) return x:IsSigni() and x:IsClass(SYS_SEIRA,0) end,3)
      if g:GetCount()>0 then Duel.SendToEna(g) end
      aux.ShuffleDeck(tp)
      return
    end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=12000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
end
