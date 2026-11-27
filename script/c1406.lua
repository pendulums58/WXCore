-- WX20-038 撃弩砲　グスクル
-- 【ライズ】あなたの《轟左砲　ドーラ》１体と《弩中砲　グスタフト》１体と《轟右砲　ドスラフ》１体の上に置く
-- 【常】：【アサシン】【ダブルクラッシュ】
-- 【常】：このシグニは対戦相手の効果によって、バニッシュされずダウンしない。
-- 【自】《ターン１回》：このシグニが対戦相手のライフクロス１枚をクラッシュしたとき、対戦相手にダメージを与える。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- 【ライズ】 「ドーラ·グスタフト·ドスラフの上」는 ＜ウェポン＞ 1체 위로 근사
  aux.AddRise(c,function(x) return x:IsSigni() and (x:IsClass(0,RACE_WEAPON)) end)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_ASSASSIN)
  e1:SetRange(LOCATION_SZONE)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_DOUBLE_CRUSH)
  e2:SetRange(LOCATION_SZONE)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EFFECT_BANISH_IMMUNE)
  e3:SetRange(LOCATION_SZONE)
  e3:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_SINGLE)
  e4:SetDescription(aux.Ability(id,2))
  e4:SetCode(EFFECT_NO_DOWN_BY_OPP)
  e4:SetRange(LOCATION_SZONE)
  c:RegisterEffect(e4)
  local e5=Effect.CreateEffect(c)
  e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e5:SetDescription(aux.Ability(id,3))
  e5:SetCode(EVENT_CRUSHED)
  e5:SetRange(LOCATION_SZONE)
  e5:SetCountLimit(1)
  e5:SetCondition(function(e,tp,eg,ep) return ep~=tp and Duel.GetCrusher()==e:GetHandler() end)
  e5:SetOperation(function(e,tp)
    Duel.Damage(1-tp)
  end)
  c:RegisterEffect(e5)
  local e6=Effect.CreateEffect(c)
  e6:SetType(EFFECT_TYPE_LIFEBURST)
  e6:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e6:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e6)
end
