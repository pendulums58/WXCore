-- WX14-027 羅原姫　Ｂｅ
-- 【自】：あなたの＜原子＞のシグニ１体が対戦相手の効果によって場を離れたとき、対戦相手の手札を１枚見ないで選び、捨てさせる。
-- 【自】：あなたが対戦相手のスペルを使用したとき、対戦相手のシグニ１体を対象とし、それをバニッシュするか、対戦相手の手札を１枚捨てさせる。
-- 【出】《青》：対戦相手のトラッシュからスペル１枚を対象とし、それをあなたの手札にあるかのように使用する。（コストは支払い、限定条件は無視しない）
-- ライフバースト：対戦相手の手札を見て１枚選び、捨てさせる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_LEAVE_FIELD)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) local x=eg:GetFirst() return x:GetOwner()==tp and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end)(x) and r&REASON_EFFECT~=0 and rp~=tp end)
  e1:SetOperation(function(e,tp)
    local h=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    if h:GetCount()>0 then Duel.SendToTrash(Duel.SelectCards(tp,h,1,1),REASON_EFFECT+REASON_DISCARD) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_USE_CARD)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg,ep) local x=eg:GetFirst() return ep==tp and x:IsType(TYPE_SPELL) and x:GetOwner()~=tp end)
  e2:SetOperation(function(e,tp)
    -- 예 = 바니시, 아니오 = 패를 버리게 한다
    if Duel.SelectYesNo(tp) then
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.Banish(tc) end
    else
      aux.Discard(1-tp,1)
    end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetEnaCost("{U}")
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_SPELL) end,tp,0,LOCATION_TRASH,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.UseFree(tc,tp,true) end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT+REASON_DISCARD)
  end)
  c:RegisterEffect(e4)
end
