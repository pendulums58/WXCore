-- WXEX1-71 求英の文章　ワサザン
-- 【常】英知＝８：あなたの＜英知＞のシグニは【ランサー】を得る。
-- 【出】：あなたの＜英知＞のシグニ１体を対象とし、ターン終了時まで、それの基本レベルを１～３いずれかのレベル１つにする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_LANCER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetCondition(aux.EichiCon(8))
  e1:SetTarget(function(e,x) return x:IsSigni() and x:IsClass(0,RACE_EICHI) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,aux.ClassFilter(0,RACE_EICHI),tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local lv=Duel.AnnounceNumber(tp,1,3)
      -- [まで] ターン終了時まで基本レベルを1〜3のいずれかにする
      local e0=Effect.CreateEffect(e:GetHandler())
      e0:SetType(EFFECT_TYPE_SINGLE)
      e0:SetCode(EFFECT_CHANGE_LEVEL)
      e0:SetValue(lv)
      e0:SetReset(RESET_PHASE+PHASE_END)
      tc:RegisterEffect(e0)
    end
  end)
  c:RegisterEffect(e2)
end
