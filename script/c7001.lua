-- WXK10-027 幻怪菌　ヅチグモ
-- 【常】：【ランサー】を持つあなたのパワー15000以上の緑のシグニは【Ｓランサー】を得る。
-- 【自】：このシグニがアタックしたとき、表記されているパワーよりパワーの高いあなたの緑のシグニ１体を対象とし、ターン終了時まで、それは【ランサー】を得る。
-- 【出】：あなたの他のシグニ１体を対象とし、ターン終了時まで、それのパワーを＋3000する。
-- ライフバースト：このターン、次にあなたがダメージを受ける場合、代わりにダメージを受けない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_S_LANCER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x:IsColor(COLOR_GREEN) and x:GetPower()>=15000 and x:HasKeyword(EFFECT_LANCER) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_GREEN) and x:GetPower()>x:GetBasePower() end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.GrantKeyword(e,tc,EFFECT_LANCER)
    end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,e:GetHandler())
  end)
  e3:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,3000)
    end
  end)
  c:RegisterEffect(e3)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_PREVENT_DAMAGE)
    e1:SetTargetRange(1,0)
    e1:SetCountLimit(1)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e9)
end
