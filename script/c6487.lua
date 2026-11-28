-- WXK04-031 コードオーダー　メレドール
-- 【常】：このシグニは《コードイート アイスケーキ》が【アクセ】として付いているかぎり、「【自】：あなたのアタックフェイズ開始時、カードを１枚引く。その後、手札から＜調理＞のシグニを１枚捨ててもよい。そうした場合、対戦相手のシグニ１体を対象とし、それをバニッシュする。」を得る。
-- 【常】：これにアクセされているシグニがバニッシュされる場合、代わりにこのカードをトラッシュに置く。
-- ライフバースト：あなたのトラッシュから＜調理＞のシグニを２枚まで手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Stringid(id,0))
  g:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  g:SetRange(LOCATION_SZONE)
  g:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  g:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
    local h=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_CHOURI) end,tp,LOCATION_HAND,0,nil)
    if h:GetCount()==0 or not Duel.SelectYesNo(tp) or Duel.SendToTrash(Duel.SelectCards(tp,h,1,1),REASON_EFFECT+REASON_DISCARD)==0 then return end
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) local h=e:GetHandler() return Duel.GetMatchingGroup(function(a) return a:GetAcceHost()==h and a:IsCardName(6504) end,h:GetControler(),LOCATION_ACCE,0,nil):GetCount()>0 end)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
  -- 【常】「これにアクセされているシグニがバニッシュされる場合、代わりにこのカードをトラッシュに置く」는 아직
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    local g=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_CHOURI) end,tp,LOCATION_TRASH,0,nil),0,2)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e9)
end
