-- WXK03-032-CB 仁の遊　ホワイトパールホープ
-- 【常】：あなたの場に《２－遊　サイクロンインターセプター》があるかぎり、このシグニのパワーは＋3000され、このシグニは対戦相手のシグニの効果を受けない。
-- 【出】《白》《無》：あなたのターンの場合、対象の対戦相手のレベル２以下のシグニ１体を手札に戻す。あなたの場に《２－遊　サイクロンインターセプター》がある場合、代わりに対象の対戦相手のシグニ１体を手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(function(x) return x:IsCardName(6415) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0 end)
  e1:SetValue(3000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e2:SetDescription(aux.Ability(id,0))
  e2:SetCode(EFFECT_IMMUNE)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e) return Duel.GetMatchingGroup(function(x) return x:IsCardName(6415) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0 end)
  e2:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and sc:IsSigni() end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  -- 대상은 발동할 때 짝이 있는지 보고 고른다(FAQ 1)
  e3:SetDescription(aux.Ability(id,1))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetEnaCost("{W}{C}")
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local pair=Duel.GetMatchingGroup(function(x) return x:IsCardName(6415) end,tp,LOCATION_SZONE,0,nil):GetCount()>0
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (pair or x:GetLevel()<=2) end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      if Duel.GetTurnPlayer()==tp then Duel.SendToHand(tc) end
    end
  end)
  c:RegisterEffect(e3)
end
