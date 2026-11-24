-- WDK08-Y17 幻水　ケロモドキ
-- 【出】《緑》：あなたの手札から＜水獣＞のシグニを３枚公開する。そうした場合、ターン終了時まで、このシグニのパワーを＋1000し、このシグニは【ランサー】を得る。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
s.suiju=aux.ClassFilter(0,RACE_SUIJU)  -- ＜水獣＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{G}")
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e2)
end
function s.op(e,tp)
  if aux.RevealFromHand(tp,s.suiju,3):GetCount()~=3 then return end
  local c=e:GetHandler()
  if not c:IsLocation(LOCATION_SZONE) then return end
  -- [まで] ターン終了時まで
  aux.AddPower(e,c,1000)
  aux.GrantKeyword(e,c,EFFECT_LANCER)
end
