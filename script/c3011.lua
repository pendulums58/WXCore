-- WX18-061 今世の張良　クロカン
-- 【ライズ】《ライズアイコン》を持つあなたのレベル２以下のシグニ１体の上に置く
-- 【起】《ターン１回》このシグニの下からカード１枚をトラッシュに置く：あなたのデッキの一番上のカードをエナゾーンに置くかカードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddRise(c,function(x) return x:IsSigni() and x:HasRiseIcon() and x:GetLevel()<=2 end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local u=e:GetHandler():GetUnderGroup()
    if chk==0 then return u:GetCount()>0 end
    Duel.SendToTrash(Duel.SelectCards(tp,u,1,1),REASON_COST)
  end)
  e1:SetOperation(function(e,tp)
    -- 예 = 에나, 아니오 = 뽑는다
    if Duel.SelectYesNo(tp) then Duel.EnaCharge(tp,1) else Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
end
