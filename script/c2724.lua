-- WX14-064 省略の徹底　ミニマリ
-- 【自】：あなたが対戦相手のセンタールリグのアタックを【ガード】するか、対戦相手のシグニのアタックを効果によって無効にしたとき、あなたのセンタールリグが＜アン＞の場合、トラッシュにあるこのカードをゲームから除外してもよい。そうした場合、カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  -- 트래시에서
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_GUARDED)
  e1:SetRange(LOCATION_TRASH)
  e1:SetCondition(function(e,tp,eg,ep) return ep==tp and (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_AN) end)() end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_TRASH) and Duel.SelectYesNo(tp) and Duel.Exclude(h)>0 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,0))
  e2:SetCode(EVENT_NEGATED)
  e2:SetRange(LOCATION_TRASH)
  e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==tp and Duel.GetTurnPlayer()~=tp and (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_AN) end)() end)
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_TRASH) and Duel.SelectYesNo(tp) and Duel.Exclude(h)>0 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e2)
end
