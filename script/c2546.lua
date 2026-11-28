-- WX12-018 真天使の未来　ガブリエルト
-- 【常】：このシグニは対戦相手の、アーツ以外の効果を受けない。
-- 【常】：あなたのルリグトラッシュにアーツが４枚以上あるかぎり、このシグニは「【自】：このシグニがアタックしたとき、あなたの場に＜天使＞のシグニが３体ある場合、対戦相手のすべてのシグニをトラッシュに置く。」を得る。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 둘
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and not sc:IsType(TYPE_ARTS) end)
  c:RegisterEffect(e1)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Stringid(id,0))
  g:SetCode(EVENT_ATTACK)
  g:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,tp,LOCATION_SZONE,0,nil):GetCount()<3 then return end
    local og=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
    if og:GetCount()>0 then Duel.SendToTrash(og,REASON_EFFECT) end
  end)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_GRANT)
  e2:SetRange(LOCATION_SZONE)
  e2:SetTargetRange(LOCATION_SIGNI,0)
  e2:SetTarget(function(e,x) return x==e:GetHandler() and Duel.GetMatchingGroup(function(a) return a:IsType(TYPE_ARTS) end,e:GetHandlerPlayer(),LOCATION_LTRASH,0,nil):GetCount()>=4 end)
  e2:SetLabelObject(g)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e3)
end
