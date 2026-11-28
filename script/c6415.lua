-- WXK03-041-CB ２－遊　サイクロンインターセプター
-- 【常】：あなたの場に《仁の遊　ホワイトパールホープ》があるかぎり、このシグニのパワーは＋3000され、このシグニは対戦相手のアーツの効果を受けない。
-- 【出】《青》《無》：あなたのターンの場合、対戦相手は手札を１枚捨てる。あなたの場に《仁の遊　ホワイトパールホープ》がある場合、代わりに対戦相手の手札を１枚見ないで選び、捨てさせる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(function(x) return x:IsCardName(6406) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0 end)
  e1:SetValue(3000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e2:SetDescription(aux.Ability(id,0))
  e2:SetCode(EFFECT_IMMUNE)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e) return Duel.GetMatchingGroup(function(x) return x:IsCardName(6406) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0 end)
  e2:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and sc:IsType(TYPE_ARTS) end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,1))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetEnaCost("{U}{C}")
  e3:SetOperation(function(e,tp,eg)
    if Duel.GetTurnPlayer()~=tp then return end
    local h=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    if h:GetCount()==0 then return end
    if Duel.GetMatchingGroup(function(x) return x:IsCardName(6406) end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then
      Duel.SendToTrash(Duel.SelectCards(tp,h,1,1),REASON_EFFECT+REASON_DISCARD)
    else
      aux.Discard(1-tp,1)
    end
  end)
  c:RegisterEffect(e3)
end
