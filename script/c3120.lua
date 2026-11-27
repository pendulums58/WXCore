-- WX20-027 羅植　アダンソニア
-- 【自】《ターン１回》：あなたのカード名に《バオバブーン》を含むシグニ１体が場に出たとき、あなたのデッキからカード１枚を探してエナゾーンに置き、デッキをシャッフルする。
-- 【出】：あなたのデッキからカード名に《バオバブーン》を含むシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- 【起】《白》《赤》《青》《緑》《黒》：対戦相手のシグニ２体を対象とし、それらをトラッシュに置く。この能力の使用コストは無色ではないカードでしか支払えない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()==tp and aux.NameHas(x,"バオバブーン") end)
  e1:SetOperation(function(e,tp)
    local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil),0,1)
    if x:GetCount()>0 then Duel.SendToEna(x) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and aux.NameHas(x,"バオバブーン") end,1)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_SZONE)
  e3:SetEnaCost("{W}{R}{U}{G}{B}")
  -- 「無色ではないカードでしか支払えない」는 아직(근사)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,2,2,nil)
  end)
  e3:SetOperation(function(e,tp)
    for x in Duel.GetTargets():Iter() do if x:IsRelateToEffect(e) then Duel.SendToTrash(x,REASON_EFFECT) end end
  end)
  c:RegisterEffect(e3)
end
