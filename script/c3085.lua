-- WX19-065 時英の経過　＃ネンレイ＃
-- 【起】トラッシュにあるこのカードをゲームから除外する：あなたのシグニ１体を対象とし、ターン終了時まで、それの基本レベルを１～４いずれかのレベル１つにする。この能力はあなたのセンタールリグが＜ママ＞の場合にしか使用できない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_TRASH)
  e1:SetCondition(function(e,tp) local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_MAMA) end)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_TRASH) end
    Duel.Exclude(e:GetHandler())
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    local lv=Duel.AnnounceNumber(tp,1,4)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_LEVEL)
    e1:SetValue(lv)
    e1:SetReset(RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
  end)
  c:RegisterEffect(e1)
end
