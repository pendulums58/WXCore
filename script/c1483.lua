-- WX18-060 幻怪　イシナゲンジョ
-- 【出】《白》：あなたのデッキから【レイヤー】を持つシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{W}")
  -- 「【レイヤー】を持つ」는 ＜怪異＞ 시그니로 근사
  e1:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_KAII)) end,1)
  end)
  c:RegisterEffect(e1)
end
