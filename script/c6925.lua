-- WXK09-052 コードアート　Ｕ・Ｓ・Ｓ
-- 【自】：このシグニがアタックしたとき、このシグニよりパワーの低い対戦相手のシグニ１体を対象とし、あなたのエナゾーンにレベル１～４の＜電機＞のシグニがそれぞれ１枚以上ある場合、それをエナゾーンに置く。
-- 【出】エナゾーンからレベル１～４の＜電機＞のシグニを１枚ずつトラッシュに置く：カードを２枚引く。ターン終了時まで、このシグニのパワーを＋8000する。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local p=e:GetHandler():GetPower()
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<p end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      if (function(p) for lv=1,4 do if Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end)(x) and x:GetLevel()==lv end,p,LOCATION_ENA,0,nil):GetCount()<1 then return false end end return true end)(tp) then Duel.SendToEna(tc) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return (function(p) for lv=1,4 do if Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end)(x) and x:GetLevel()==lv end,p,LOCATION_ENA,0,nil):GetCount()<1 then return false end end return true end)(tp) end
    local g=Group.CreateGroup()
    for lv=1,4 do
      local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(y) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end)(y) and y:GetLevel()==lv end,tp,LOCATION_ENA,0,nil),1,1):GetFirst()
      g:AddCard(x)
    end
    Duel.SendToTrash(g,REASON_COST)
  end)
  e2:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,2)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then aux.AddPower(e,h,8000) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e9)
end
