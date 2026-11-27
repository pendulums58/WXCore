-- WX18-080 下町の酔魔　センベロ
-- 【自】《ターン１回》：効果１つによってあなたのデッキからカードが５枚以上トラッシュに置かれたとき、あなたのデッキの一番上のカードをエナゾーンに置くか、カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) return r&REASON_EFFECT~=0 and eg:Filter(function(x) return x:GetOwner()==tp and x:IsPreviousLocation(LOCATION_MDECK) end,nil):GetCount()>=5 end)
  e1:SetOperation(function(e,tp)
    if Duel.SelectYesNo(tp) then Duel.EnaCharge(tp,1) else Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
end
