-- WXK10-091 蛙王の童話　ハインリヒ
-- 【出】：対戦相手のレベル３以下のシグニ１体を対象とし、それをトラッシュに置く。対戦相手は自分のデッキからこの方法でトラッシュに置かれたシグニのレベル以下のシグニを１枚まで探して場に出し、デッキをシャッフルする。そのシグニの【出】能力は発動しない。
-- 【起】このシグニを場からトラッシュに置く：対戦相手のトラッシュから＜美巧＞ではないレベル３以下のシグニ１枚を対象とし、それを傀儡状態であなたの場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local lv=tc:GetLevel()
      if Duel.SendToTrash(tc,REASON_EFFECT)==0 then return end
      local x=aux.Search(1-tp,function(y) return y:IsSigni() and y:GetLevel()<=lv end,1):GetFirst()
      if x then Duel.PutOnField(x,1-tp,true) end
      aux.ShuffleDeck(1-tp)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_SZONE) end
    Duel.SendToTrash(e:GetHandler(),REASON_COST)
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 and not x:IsClass(0,RACE_BIKOU) end,tp,0,LOCATION_TRASH,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.PutOnField(tc,tp)
    end
  end)
  c:RegisterEffect(e2)
end
