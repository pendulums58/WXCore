-- WX21-054 幻竜　ディノス
-- 【常】：対戦相手のエナゾーンにカードが５枚以上あるかぎり、このシグニは「【自】：このシグニが対戦相手にダメージを与えたとき、対戦相手のエナゾーンからカード１枚を対象とし、それをトラッシュに置く。」を得る。
-- 【出】：あなたの手札から赤と緑の＜龍獣＞のシグニを１枚ずつ公開するか、このシグニを場からトラッシュに置く。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 상대 에나 5장 이상이면 얻는다
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  g:SetCode(EVENT_DAMAGE)
  g:SetRange(LOCATION_SZONE)
  g:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return ep~=tp and Duel.GetCrusher()==e:GetHandler() end)
  g:SetOperation(function(e,tp)
    local x=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ENA,1,1,nil):GetFirst()
    if x then Duel.SendToTrash(x,REASON_EFFECT) end
  end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),0,LOCATION_ENA,nil):GetCount()>=5 end)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local r=Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end)(x) and x:IsColor(COLOR_RED) end,tp,LOCATION_HAND,0,nil)
    local g=Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end)(x) and x:IsColor(COLOR_GREEN) end,tp,LOCATION_HAND,0,nil)
    -- 예 = 공개, 아니오 = 이 시그니를 트래시에
    if r:GetCount()>0 and g:GetCount()>0 and Duel.SelectYesNo(tp) then
      local d=Duel.SelectCards(tp,r,1,1)
      d:Merge(Duel.SelectCards(tp,g:Filter(function(x) return not d:IsContains(x) end,nil),1,1))
      Duel.RevealCards(d)
    else
      local h=e:GetHandler()
      if h:IsLocation(LOCATION_SZONE) then Duel.SendToTrash(h,REASON_EFFECT) end
    end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e3)
end
