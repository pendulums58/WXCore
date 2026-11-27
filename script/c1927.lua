-- WX02-039 幻獣　ハチ
-- 【起】《ダウン》：あなたのデッキの一番上を公開する。それが＜空獣＞か＜地獣＞のシグニの場合、それを手札に加える。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  -- 맞지 않으면 덱 위에 그대로(FAQ 1)
  e1:SetOperation(function(e,tp)
    local top=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not top then return end
    Duel.RevealCards(top)
    if (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KUJU) or x:IsClass(0,RACE_CHIJU)) end)(top) then Duel.SendToHand(top) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
