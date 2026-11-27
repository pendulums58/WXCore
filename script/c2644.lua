-- WX13-073 幻水　ホンビウオ
-- 【自】：このシグニがバニッシュされたとき、対戦相手のライフクロスの一番上とデッキの一番上を見る。あなたはそれらを入れ替えてもよい。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetOperation(function(e,tp)
    local l=Duel.GetMatchingGroup(nil,1-tp,LOCATION_LIFE,0,nil):GetFirst()
    local d=Duel.GetDecktopGroup(1-tp,1):GetFirst()
    if not (l and d) then return end
    Duel.ConfirmCards(tp,l)
    Duel.ConfirmCards(tp,d)
    -- 맞바꾼다: 라이프 맨 위를 덱 위로, 덱 위를 라이프로(근사)
    if Duel.SelectYesNo(tp) then
      Duel.SendToLife(d)
      Duel.SendToDeckPosition(l,1)
    end
  end)
  c:RegisterEffect(e1)
end
