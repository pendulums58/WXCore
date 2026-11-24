-- WD10-009 弩砲　ヘッケラ
-- 《クロスアイコン》《轟砲　コック》の右
-- 【クロス常】：このシグニの基本パワーは15000になる。
-- 【クロス自】：このシグニが《ヘブン》したとき、《赤》を支払ってもよい。そうした場合、対戦相手のライフクロス１枚をクラッシュする。
-- ライフバースト：パワー10000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,1198,CROSS_RIGHT)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_SET_BASE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():IsCross() end)
  e1:SetValue(15000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_HEAVEN)
  e2:SetRange(LOCATION_SZONE)
  e2:SetOperation(function(e,tp)
    if not (Duel.CanPayEna(tp,"{R}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{R}"),REASON_COST)
    Duel.Crush(1-tp,1)
  end)
  c:RegisterEffect(e2)
  -- 「対戦相手の」가 없다: 양쪽 시그니가 대상
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,s.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and s.filter(tc) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e3)
end
function s.filter(c) return c:IsSigni() and c:GetPower()<=10000 end
