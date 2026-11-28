-- WXK03-063 魔界の千夜　マリッド
-- 【自】：あなたのアタックフェイズ開始時、あなたの手札が０枚の場合、《青》《青》を支払ってもよい。そうした場合、ターン終了時まで、このシグニは【アサシン】を得る。
-- （【アサシン】を持つシグニがアタックすると正面のシグニとバトルをせず対戦相手にダメージを与える）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp and Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()==0 end)
  e1:SetOperation(function(e,tp,eg)
    if not (Duel.CanPayEna(tp,"{U}{U}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{U}{U}"),REASON_COST)
    aux.GrantKeyword(e,e:GetHandler(),EFFECT_ASSASSIN)
  end)
  c:RegisterEffect(e1)
end
