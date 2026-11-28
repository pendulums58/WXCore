-- WXK03-037 魔界の千夜　ソロモーン
-- 【自】：対戦相手のターン終了時、あなたの手札が１枚以下の場合、あなたのデッキから＜悪魔＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  -- 발동할 때 손패를 본다(FAQ 1)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TURN_END)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  e1:SetOperation(function(e,tp,eg)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()<=1 then aux.SearchToHand(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_AKUMA) end,1) end
  end)
  c:RegisterEffect(e1)
end
