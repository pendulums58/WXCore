-- PR-426 篭手　エルゼ
-- 【常】：あなたのライフクロスが１枚以下で、このシグニが中央のシグニゾーンにあるかぎり、このシグニのパワーは＋4000され、このシグニは「【自】：このシグニがアタックしたとき、正面のシグニ１体を対象とし、それをバニッシュする。」を得る。
-- 【自】《ターン１回》：あなたのライフクロス１枚がクラッシュされたとき、対戦相手のレベル３以下のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：あなたのデッキからレベル３以下の白のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Ability(id,0))
  g:SetCode(EVENT_ATTACK)
  -- 【シャドウ】는 대상으로 할 수 없다(FAQ 1)
  g:SetOperation(function(e,tp)
    local f=Duel.GetFrontZone(e:GetHandler():GetZone())
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetZone()==f end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x==e:GetHandler() and x:IsInZone("signi_center") and Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_LIFE,0,nil):GetCount()<=1 end)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e2:SetDescription(aux.Ability(id,0))
  e2:SetCode(EFFECT_UPDATE_POWER)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e) local h=e:GetHandler() return h:IsInZone("signi_center") and Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_LIFE,0,nil):GetCount()<=1 end)
  e2:SetValue(4000)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,1))
  e3:SetCode(EVENT_CRUSHED)
  e3:SetRange(LOCATION_SZONE)
  e3:SetCountLimit(1)
  e3:SetCondition(function(e,tp,eg,ep) return ep==tp end)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetOperation(function(e,tp)
    local g=aux.Search(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 and x:IsColor(COLOR_WHITE) end,1)
    if g:GetCount()>0 then
      Duel.RevealCards(g)
      Duel.SendToHand(g)
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e4)
end
