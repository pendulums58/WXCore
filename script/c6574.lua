-- WXK05-032 羅植　サイサ
-- 【常】：このシグニは新たに場に出すことができない。
-- 【自】：このシグニがアタックしたとき、対戦相手のすべてのシグニをトラッシュに置く。
-- ライフバースト：あなたのトラッシュから＜植物＞のシグニ１枚を対象とし、それを手札に加えるか場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】 새로 장에 낼 수 없다(개화로만)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_CANNOT_PLAY)
  e1:SetRange(LOCATION_HAND+LOCATION_MDECK+LOCATION_TRASH+LOCATION_ENA)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetOperation(function(e,tp,eg)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_SHOKUBUTSU) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      if not (Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==1 and Duel.PutOnField(tc,tp)) then Duel.SendToHand(tc) end
    end
  end)
  c:RegisterEffect(e9)
end
