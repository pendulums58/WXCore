-- WX21-Re07 シャボン・ウェーブ
-- 以下の２つから１つを選ぶ。
-- ①あなたのデッキからそれぞれ名前の異なる＜天使＞のシグニを１０枚まで探してトラッシュに置き、デッキをシャッフルする。
-- ②対戦相手のターンの場合、ターン終了時まで、あなたのすべての＜天使＞のシグニは「【常】：バニッシュされない。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCondition(function() return true end)
  e1:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==0 then
      local seen,out={},Group.CreateGroup()
      for x in Duel.SelectCards(tp,Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,tp,LOCATION_MDECK,0,nil),0,10):Iter() do
        if not seen[x:GetCode()] then seen[x:GetCode()]=true out:AddCard(x) end
      end
      if out:GetCount()>0 then Duel.SendToTrash(out,REASON_EFFECT) end
      aux.ShuffleDeck(tp)
      return
    end
    if Duel.GetTurnPlayer()==tp then return end
    for tc in Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,tp,LOCATION_SZONE,0,nil):Iter() do
    local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_CANNOT_BANISH)
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:RegisterEffect(e1)
    end
  end)
  c:RegisterEffect(e1)
end
