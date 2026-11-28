-- WXK09-069 航海の蒼天　マナナン
-- 【常】：対戦相手の手札が２枚以下であるかぎり、このシグニのパワーは＋5000される。
-- 【自】《ターン１回》：ガードステップ以外であなたが手札を１枚捨てたとき、あなたのデッキの上からカードを２枚見る。その中から好きな枚数のカードをトラッシュに置き、残りを好きな順番でデッキの一番上に戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(nil,1-e:GetHandlerPlayer(),LOCATION_HAND,0,nil):GetCount()<=2 end)
  e1:SetValue(5000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_TO_TRASH)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCondition(function(e,tp,eg,ep,ev,re,r) if (r&REASON_GUARD)~=0 or (r&REASON_DISCARD)==0 then return false end for x in eg:Iter() do if x:IsPreviousLocation(LOCATION_HAND) and x:GetOwner()==tp then return true end end return false end)
  e2:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,2)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local tr=Duel.SelectCards(tp,g,0,g:GetCount())
    if tr:GetCount()>0 then Duel.SendToTrash(tr,REASON_EFFECT) end
    local rest=g:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>1 then aux.ToDeckTopInOrder(tp,rest) end
  end)
  c:RegisterEffect(e2)
end
