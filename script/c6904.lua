-- WXK09-031 コードハート　Ｖ・∀・Ｃ
-- 【自】：このシグニがアタックしたとき、あなたのエナゾーンにレベル１～４の＜電機＞のシグニがそれぞれ２枚以上ある場合、対象の対戦相手のシグニ１体をエナゾーンに置く。それぞれ３枚以上ある場合、代わりに対戦相手のすべてのシグニをトラッシュに置く。
-- 【自】：このカードがトラッシュからエナゾーンに置かれたとき、このカードをエナゾーンから手札に加えてもよい。
-- ライフバースト：あなたのトラッシュから＜電機＞のシグニ１枚を対象とし、それを手札に加えるか場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp,eg)
    if (function(p) for lv=1,4 do if Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end)(x) and x:GetLevel()==lv end,p,LOCATION_ENA,0,nil):GetCount()<3 then return false end end return true end)(tp) then
      local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
      if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    elseif (function(p) for lv=1,4 do if Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end)(x) and x:GetLevel()==lv end,p,LOCATION_ENA,0,nil):GetCount()<2 then return false end end return true end)(tp) then
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.SendToEna(tc) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_TO_ENA)
  e2:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_TRASH) end)
  e2:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_ENA) and Duel.SelectYesNo(tp) then Duel.SendToHand(h) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then Duel.SendToHand(tc) else Duel.PutOnField(tc,tp) end
    end
  end)
  c:RegisterEffect(e9)
end
