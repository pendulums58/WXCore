-- WX14-029 参ノ遊　ウォスラ
-- 【自】：カード１枚があなたのエナゾーンから手札に移動したとき、このシグニをバニッシュしてもよい。その後、この効果でこのシグニをバニッシュしていた場合、あなたのエナゾーンからシグニ１枚を対象とし、それをダウン状態で場に出す。
-- 【自】：このカードが手札かデッキからトラッシュに置かれたとき、あなたのセンタールリグが＜アイヤイ＞の場合、このカードをトラッシュからエナゾーンに置く。
-- ライフバースト：あなたのデッキの一番上のカードをエナゾーンに置く。それが＜遊具＞のシグニの場合、追加でカードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_HAND)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetOwner()==tp and x:IsPreviousLocation(LOCATION_ENA) end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if not (h:IsLocation(LOCATION_SZONE) and Duel.SelectYesNo(tp)) or Duel.Banish(h)==0 then return end
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_ENA,0,1,1,nil):GetFirst()
    if tc then Duel.PutOnField(tc,tp,false,true) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_TO_TRASH)
  e2:SetCondition(function(e) local h=e:GetHandler() return h:IsPreviousLocation(LOCATION_HAND) or h:IsPreviousLocation(LOCATION_MDECK) end)
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_AIYAI) end)() and h:IsLocation(LOCATION_TRASH) then Duel.SendToEna(h) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    local x=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not x then return end
    Duel.SendToEna(x)
    if (function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end)(x) then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e3)
end
