-- WX07-025 弩砲　ファイヤレイジ
-- 《クロスアイコン》《轟砲　マスケッタ》の左
-- 【クロス常】：このシグニの基本パワーは15000になる。
-- 【出】《赤》：対戦相手のパワー7000以下のシグニ１体を対象とし、それをバニッシュする。
-- 【クロス自】：このシグニが《ヘブン》したとき、対戦相手のパワー15000以下のシグニ１体を対象とし、《赤》を支払ってもよい。そうした場合、それをバニッシュする。
-- ライフバースト：対戦相手のパワー10000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,2206,CROSS_LEFT)
  -- [の間] 【クロス常】
  aux.BasePower(c,15000,function(e) return e:GetHandler():IsCross() end)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{R}")
  e2:SetTarget(aux.BanishPowerTarget(7000))
  e2:SetOperation(aux.BanishOp)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetCode(EVENT_HEAVEN)
  e3:SetRange(LOCATION_SZONE)
  e3:SetTarget(aux.BanishPowerTarget(15000))
  e3:SetOperation(function(e,tp)
    if not (Duel.CanPayEna(tp,"{R}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{R}"),REASON_COST)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetTarget(aux.BanishPowerTarget(10000))
  e4:SetOperation(aux.BanishOp)
  c:RegisterEffect(e4)
end
