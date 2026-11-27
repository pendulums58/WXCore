-- WX10-030 羅石　イリスアゲート
-- 【自】：あなたのターン終了時、あなたは手札を１枚捨てる。
-- 【自】：あなたがスペルを使用したとき、このシグニをアップする。
-- 【起】《ダウン》：ターン終了時まで、このシグニは【ダブルクラッシュ】を得る。
-- 【起】《赤》《ダウン》：このシグニのパワー以下の対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：カードを１枚引く。その後、デッキの一番上を公開し、それが＜鉱石＞か＜宝石＞のシグニの場合、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TURN_END)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e1:SetOperation(function(e,tp)
    aux.Discard(tp,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_USE_CARD)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg,ep) return ep==tp and eg:GetFirst():IsType(TYPE_SPELL) end)
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then Duel.Up(h) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_SZONE)
  e3:SetCost(aux.SelfDownCost)
  e3:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then aux.GrantKeyword(e,h,EFFECT_DOUBLE_CRUSH) end  -- [まで]
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_IGNITION)
  e4:SetDescription(aux.Ability(id,3))
  e4:SetRange(LOCATION_SZONE)
  e4:SetEnaCost("{R}")
  e4:SetCost(aux.SelfDownCost)
  e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local p=e:GetHandler():GetPower()
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=p end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e4:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e4)
  local e5=Effect.CreateEffect(c)
  e5:SetType(EFFECT_TYPE_LIFEBURST)
  e5:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
    local x=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not x then return end
    Duel.RevealCards(x)
    if (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KOUSEKI) or x:IsClass(0,RACE_HOUSEKI)) end)(x) then Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e5)
end
