-- WX16-067 追英の文章　＃オイツキ＃
-- 【常】英知=８：このシグニによってクラッシュされたカードのライフバーストは発動しない。（あなたの場にある＜英知＞のシグニのレベルの合計がちょうど８であるかぎり有効になる）
-- 【自】：このシグニがアタックしたとき、あなたの＜英知＞のシグニ１体を対象とし、ターン終了時まで、それのレベルを＋１するか－１してもよい。この効果でレベルは０以下にはならない。
local s,id=GetID()
function s.initial_effect(c)
  -- 【常】 英知=8 「クラッシュされたカードのライフバーストは発動しない」는 아직(근사 없음)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_EICHI)) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    local m=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
    local v=m==0 and 1 or m==1 and -1 or 0
    if v<0 and tc:GetLevel()<=1 then v=0 end
    if v==0 then return end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_LEVEL)
    e1:SetValue(v)
    e1:SetReset(RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
  end)
  c:RegisterEffect(e1)
end
