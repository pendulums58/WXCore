-- WXK04-015 鎮護国禍
-- 【出】：以下の４つから２つを選ぶ。
-- ①対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- ②あなたのトラッシュから無色ではないシグニ１枚を対象とし、それを手札に加える。
-- ③対戦相手の手札を１枚見ないで選び、捨てさせる。
-- ④【エナチャージ１】
-- 【起】このキーを場からルリグトラッシュに置く：あなたの赤のシグニ１体を対象とし、ターン終了時まで、それは【ダブルクラッシュ】を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    for _,m in ipairs(Duel.SelectModes(tp,2,2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))) do
      if m==0 then
        local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
        if tc then Duel.Banish(tc) end
      elseif m==1 then
        local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetColor()~=0 end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
        if tc then Duel.SendToHand(tc) end
      elseif m==2 then
        local h=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
        if h:GetCount()>0 then Duel.SendToTrash(Duel.SelectCards(tp,h,1,1),REASON_EFFECT+REASON_DISCARD) end
      else
        Duel.EnaCharge(tp,1)
      end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_KEY)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) end
    Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_RED) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.GrantKeyword(e,tc,EFFECT_DOUBLE_CRUSH)
    end
  end)
  c:RegisterEffect(e2)
end
