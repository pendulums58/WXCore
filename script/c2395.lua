-- WX10-017 アイヤイ★レイズ
-- 【自】《ターン１回》：あなたのシグニ１体が効果によって場に出たとき、あなたのデッキから＜遊具＞のシグニ１枚を探してエナゾーンに置き、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) local x=eg:GetFirst() return x:GetControler()==tp and x:IsSigni() and r&REASON_EFFECT~=0 end)
  e1:SetOperation(function(e,tp)
    local x=aux.Search(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end,1):GetFirst()
    if x then Duel.SendToEna(x) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
end
