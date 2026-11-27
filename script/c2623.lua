-- WX13-052 参ノ遊　コイノボリ
-- 【自】：このシグニが対戦相手のシグニ１体をバニッシュしたとき、あなたのデッキの一番上を公開する。それが＜遊具＞のシグニの場合、このシグニをバニッシュしてもよい。そうした場合、この効果で公開したシグニをダウン状態で場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) return eg:GetFirst():GetOwner()~=tp and Duel.GetBanisher()==e:GetHandler() end)
  e1:SetOperation(function(e,tp)
    local x=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not x then return end
    Duel.RevealCards(x)
    local h=e:GetHandler()
    if not ((function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end)(x) and h:IsLocation(LOCATION_SZONE) and Duel.SelectYesNo(tp)) or Duel.Banish(h)==0 then return end
    Duel.PutOnField(x,tp,false,true)
  end)
  c:RegisterEffect(e1)
end
