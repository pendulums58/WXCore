-- WX20-048 ドライ＝アリサエマ
-- 【出】：あなたのトラッシュから《ドライ＝アリサエマ》以外のレベル３以下の＜毒牙＞のシグニ１枚を対象とし、それを場に出す。ターン終了時、それを場からトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_DOKUGA)) end)(x) and x:GetLevel()<=3 and not x:IsCardName(id) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and Duel.PutOnField(tc,tp)) then return end
    local out=Group.CreateGroup(tc)
    local e9=Effect.CreateEffect(e:GetHandler())
    e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e9:SetCode(EVENT_TURN_END)
    e9:SetOperation(function() local g=out:Filter(function(x) return x:IsLocation(LOCATION_SZONE) end,nil) if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end end)
    e9:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e9,tp)
  end)
  c:RegisterEffect(e1)
end
