-- WXEX1-80Re 羅星　リンゼ
-- 【自】：このシグニがアタックしたとき、次のあなたのターンまで、対戦相手はアーツとスペルを使用できない。
-- 【自】：あなたのターン終了時、あなたは手札をすべて捨ててもよい。この方法でカードを１枚以上捨てた場合、捨てた枚数に１を加えた枚数のカードを引く。
-- 【出】：あなたのトラッシュから《篭手　エルゼ》１枚を対象とし、あなたのライフクロスが１枚以下の場合、それを場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    -- [まで] 次のあなたのターンまで、対戦相手はアーツとスペルを使用できない
    local e0=Effect.CreateEffect(e:GetHandler())
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_CANNOT_USE)
    e0:SetTargetRange(0,LOCATION_HAND+LOCATION_LDECK)
    e0:SetTarget(function(ef,x) return x:IsType(TYPE_SPELL) or x:IsType(TYPE_ARTS) end)
    e0:SetReset(RESET_PHASE+PHASE_END+RESET_MY_TURN)
    Duel.RegisterEffect(e0,tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_PHASE_START+PHASE_END)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e2:SetOperation(function(e,tp)
    local hg=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    if hg:GetCount()==0 or not Duel.SelectYesNo(tp) then return end
    local n=Duel.SendToTrash(hg,REASON_DISCARD+REASON_EFFECT)
    if n>0 then Duel.Draw(tp,n+1) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsCardName(269) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()>1 then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e3)
end
