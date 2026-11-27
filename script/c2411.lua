-- WX10-039 大剣　ハチキュー
-- 【出】手札から＜アーム＞のシグニを１枚捨てる：あなたのデッキから＜アーム＞か＜ウェポン＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- 【出】手札から＜ウェポン＞のシグニを１枚捨てる：対戦相手のパワー8000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(aux.DiscardCost(1,function(x) return x:IsSigni() and (x:IsClass(0,RACE_ARM)) end))
  e1:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_ARM) or x:IsClass(0,RACE_WEAPON)) end,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetCost(aux.DiscardCost(1,function(x) return x:IsSigni() and (x:IsClass(0,RACE_WEAPON)) end))
  e2:SetTarget(aux.BanishPowerTarget(8000))
  e2:SetOperation(aux.BanishOp)
  c:RegisterEffect(e2)
end
