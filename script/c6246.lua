-- WXK01-063 貫穿
-- あなたの緑のシグニ１体を対象とし、ターン終了時まで、それのパワーを＋2000し、それは【Ｓランサー】を得る。
-- （【Ｓランサー】を持つシグニがバトルでシグニをバニッシュしたとき、対戦相手のライフクロスがある場合はそれを１枚クラッシュする。無い場合は対戦相手にダメージを与える）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_GREEN) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      -- [まで] ターン終了時まで
      aux.AddPower(e,tc,2000)
      aux.GrantKeyword(e,tc,EFFECT_S_LANCER)
    end
  end)
  c:RegisterEffect(e1)
end
