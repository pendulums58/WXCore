-- WXK07-073 羅菌　ビタミンB1
-- 【出】：あなたのデッキの一番上のカードをこのシグニの【チャーム】にする。
-- 【起】《メインフェイズアイコン》《アタックフェイズアイコン》このシグニに付いている【チャーム】１枚をトラッシュに置く：シグニ１体を対象とし、ターン終了時まで、それのパワーを＋7000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    local x=Duel.GetDecktopGroup(tp,1):GetFirst()
    if x and h:IsLocation(LOCATION_SZONE) and not h:GetCharm() then Duel.Charm(x,h) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local ch=e:GetHandler():GetCharm()
    if chk==0 then return ch~=nil end
    Duel.SendToTrash(ch,REASON_COST)
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,7000)
    end
  end)
  c:RegisterEffect(e2)
end
