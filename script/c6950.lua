-- WXK09-077 コードアート　Ｅ・Ｍ・Ｂ
-- 【自】：このシグニに《改造素材》が使用されたとき、【エナチャージ２】をする。
-- 【自】：このシグニがアタックしたとき、あなたのエナゾーンにレベル１～４の＜電機＞のシグニがそれぞれ１枚以上ある場合、カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_CUSTOM+6974)
  e1:SetOperation(aux.EnaChargeOp(2))
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetOperation(function(e,tp,eg)
    if (function(p) for lv=1,4 do if Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end)(x) and x:GetLevel()==lv end,p,LOCATION_ENA,0,nil):GetCount()<1 then return false end end return true end)(tp) then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e2)
end
