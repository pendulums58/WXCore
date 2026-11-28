-- WXK05-010 時雨の調　ゆきめ
-- 【出】：以下の２つから２つまで選ぶ。同じ選択肢を２回選んでもよい。
-- ①対戦相手のシグニ１体を対象とし、それを手札に戻す。
-- ②あなたのデッキからシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- 【起】このキーを場からルリグトラッシュに置く：対戦相手のキー１枚を対象とし、ターン終了時まで、それは能力を失う。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    for _=1,2 do
      local m=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
      if m==0 then
        local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
        if tc then Duel.SendToHand(tc) end
      else
        aux.SearchToHand(tp,Card.IsSigni,1)
      end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_KEY)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) end
    Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,0,LOCATION_KEY,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_LOSE_ABILITY)
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:RegisterEffect(e1)
    end
  end)
  c:RegisterEffect(e2)
end
