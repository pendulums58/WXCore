-- WXK02-051 円弧の精炎
-- あなたのデッキから《ライズアイコン》を持つシグニ１枚を探して場に出し、デッキをシャッフルする。その後、この方法で場に出したシグニのパワー以下の対戦相手のシグニ１体を対象とし、それをバニッシュする。（【ライズ】の条件を満たさなければ場に出せない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    local x=aux.Search(tp,function(y) return y:IsSigni() and y:HasRiseIcon() end,1):GetFirst()
    local put=x and Duel.PutOnField(x,tp) and x or nil
    aux.ShuffleDeck(tp)
    if not (put and put:IsLocation(LOCATION_SZONE)) then return end
    local pw=put:GetPower()
    local tc=Duel.SelectTarget(tp,function(y) return y:IsSigni() and y:GetPower()<=pw end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
end
