-- WXEX1-33 羅輝石　ロードナイト
-- 【常】：このシグニはパワーが10000以上であるかぎり、【アサシン】を得る。
-- 【常】：このシグニはパワーが20000以上であるかぎり、【ダブルクラッシュ】を得る。30000以上であるかぎり、代わりに【トリプルクラッシュ】を得る。
-- 【自】：あなたが赤のスペルを使用したとき、ターン終了時まで、このシグニのパワーを＋5000する。
-- ライフバースト：あなたのトラッシュから赤のカード１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_ASSASSIN)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():GetPower()>=10000 end)
  c:RegisterEffect(e1)
  -- [の間] 【常】
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_DOUBLE_CRUSH)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e) local p=e:GetHandler():GetPower() return p>=20000 and p<30000 end)
  c:RegisterEffect(e2)
  local e2b=Effect.CreateEffect(c)
  e2b:SetType(EFFECT_TYPE_SINGLE)
  e2b:SetCode(EFFECT_TRIPLE_CRUSH)
  e2b:SetRange(LOCATION_SZONE)
  e2b:SetCondition(function(e) return e:GetHandler():GetPower()>=30000 end)
  c:RegisterEffect(e2b)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_USE_CARD)
  e3:SetRange(LOCATION_SZONE)
  e3:SetCondition(function(e,tp,eg,ep)
    local sc=eg:GetFirst()
    return ep==tp and sc and sc:IsType(TYPE_SPELL) and sc:IsColor(COLOR_RED)
  end)
  e3:SetOperation(function(e,tp)
    aux.AddPower(e,e:GetHandler(),5000)
  end)
  c:RegisterEffect(e3)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsColor(COLOR_RED) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e9:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e9)
end
