-- WDK08-L12 紅蓮の使い魔　イザナミ
-- 【起】《ターン１回》《赤》：あなたのデッキから《紅蓮の使い魔　イザナミ》以外の＜紅蓮＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
s.guren=aux.ClassFilter(0,RACE_GUREN)  -- ＜紅蓮＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetEnaCost("{R}")
  e1:SetOperation(function(e,tp)
    local self=e:GetHandler()
    aux.SearchToHand(tp,function(x) return s.guren(x) and not x:IsSameName(self) end,1)
  end)
  c:RegisterEffect(e1)
end
