-- WX06-011 シャボン・サモン
-- 以下の２つから１つを選ぶ。
-- ①あなたのデッキから＜天使＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- ②あなたの手札から＜天使＞のシグニ１枚を場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==0 then
      aux.SearchToHand(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,1)
    else
      local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,tp,LOCATION_HAND,0,nil),0,1):GetFirst()
      if x then Duel.PutOnField(x,tp) end
    end
  end)
  c:RegisterEffect(e1)
end
