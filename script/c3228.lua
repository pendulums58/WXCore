-- WX22-002 永らえし使　リワト＝エナ
-- 【常】：対戦相手のターンの間、対戦相手のセンタールリグのリミットは１減る。
-- 【自】：あなたのアタックフェイズ開始時、あなたの場に
-- 白の＜天使＞のシグニがある場合、対象の対戦相手のシグニ１体を手札に戻す。
-- 赤の＜天使＞がある場合、対象の対戦相手のシグニ１体をバニッシュする。
-- 青の＜天使＞がある場合、対戦相手は手札を１枚捨てる。
-- 緑の＜天使＞がある場合、あなたのデッキの一番上のカードをエナゾーンに置く。
-- 黒の＜天使＞がある場合、あなたのトラッシュから対象のシグニ１枚を手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_LIMIT)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(0,LOCATION_LRIG)
  e1:SetCondition(function(e) return Duel.GetTurnPlayer()~=e:GetHandlerPlayer() end)
  e1:SetValue(-1)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e2:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e2:SetOperation(function(e,tp)
    local has=function(col) return Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end)(x) and x:IsColor(col) end,tp,LOCATION_SZONE,0,nil):GetCount()>0 end
    if has(COLOR_WHITE) then local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() if tc then Duel.SendToHand(tc) end end
    if has(COLOR_RED) then local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() if tc then Duel.Banish(tc) end end
    if has(COLOR_BLUE) then aux.Discard(1-tp,1) end
    if has(COLOR_GREEN) then Duel.EnaCharge(tp,1) end
    if has(COLOR_BLACK) then local x=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil):GetFirst() if x then Duel.SendToHand(x) end end
  end)
  c:RegisterEffect(e2)
end
