-- WX08-029 音階の右律　トオン
-- 《クロスアイコン》《音階の左巧　ヘオン》の右
-- 【クロス常】：このシグニの基本パワーは15000になる。
-- 【起】《アタックフェイズアイコン》《緑》：ターン終了時まで、このシグニは「【常】：バニッシュされない。」を得る。
-- 【クロス自】：このシグニが《ヘブン》したとき、あなたのエナゾーンからカード１枚を対象とし、それを手札に加えてもよい。
-- ライフバースト：このターン、あなたはダメージを受けない。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,2289,CROSS_RIGHT)
  -- [の間] 【クロス常】
  aux.BasePower(c,15000,function(e) return e:GetHandler():IsCross() end)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_SZONE)
  e2:SetEnaCost("{G}")
  e2:SetTiming(TIMING_ATTACK)
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then aux.GrantKeyword(e,h,EFFECT_CANNOT_BANISH) end  -- [まで]
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetCode(EVENT_HEAVEN)
  e3:SetRange(LOCATION_SZONE)
  e3:SetOperation(function(e,tp)
    local tc=Duel.SelectTarget(tp,nil,tp,LOCATION_ENA,0,0,1,nil):GetFirst()
    if tc then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetOperation(function(e,tp)
    -- [の間] 「このターン」
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_NO_DAMAGE)
    e1:SetTargetRange(1,0)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e4)
end
