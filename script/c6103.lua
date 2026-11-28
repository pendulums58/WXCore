-- WXEX1-69 幻竜　ディプロドクス
-- 【自】：このシグニがアタックしたとき、あなたのエナゾーンから＜龍獣＞のシグニを１枚まで対象とし、手札から＜龍獣＞のシグニを３枚まで公開する。この方法でシグニを２枚以上公開した場合、それを手札に加える。３枚公開した場合、ターン終了時まで、このシグニのパワーは＋2000され、このシグニは【ランサー】を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,aux.ClassFilter(0,RACE_RYUJU),tp,LOCATION_ENA,0,0,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    local pick=Duel.SelectCards(tp,Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_RYUJU),tp,LOCATION_HAND,0,nil),0,3)
    local n=pick:GetCount()
    if n>0 then Duel.RevealCards(pick) end
    if n>=2 and tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
    if n>=3 then
      local h=e:GetHandler()
      if h:IsLocation(LOCATION_SZONE) then
        aux.AddPower(e,h,2000)
        aux.GrantKeyword(e,h,EFFECT_LANCER)
      end
    end
  end)
  c:RegisterEffect(e1)
end
