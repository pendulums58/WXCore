-- WXK07-077 羅菌　ビタミンB2
-- 【出】：【チャーム】が付いているあなたのシグニ１体を対象とし、ターン終了時まで、それのパワーを＋1000し、それは【ランサー】を得る。 （【ランサー】を持つシグニがバトルでシグニをバニッシュしたとき、対戦相手のライフクロスを１枚クラッシュする）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetCharm()~=nil end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,1000)
      aux.GrantKeyword(e,tc,EFFECT_LANCER)
    end
  end)
  c:RegisterEffect(e1)
end
