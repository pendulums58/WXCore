-- WX13-075 幻水　タチウオ
-- 【自】：このシグニがバニッシュされたとき、対戦相手のライフクロスの一番上を見る。あなたはそれをトラッシュに置いてもよい。そうした場合、対戦相手のデッキの一番上のカードをライフクロスに加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetOperation(function(e,tp)
    local l=Duel.GetMatchingGroup(nil,1-tp,LOCATION_LIFE,0,nil):GetFirst()
    if not l then return end
    Duel.ConfirmCards(tp,l)
    if Duel.SelectYesNo(tp) and Duel.SendToTrash(l,REASON_EFFECT)>0 then
      local d=Duel.GetDecktopGroup(1-tp,1)
      if d:GetCount()>0 then Duel.SendToLife(d) end
    end
  end)
  c:RegisterEffect(e1)
end
