-- WXK05-040 コードイート　アイスコーン
-- 【自】：対戦相手のターン終了時、このシグニを場から手札に戻す。
-- 【自】：このカードが【アクセ】としてシグニに付いたとき、対戦相手のライフクロスの一番上を見る。あなたはそれをトラッシュに置いてもよい。そうした場合、対戦相手のデッキの一番上のカードをライフクロスに加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TURN_END)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  e1:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then Duel.SendToHand(h) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ACCE)
  e2:SetOperation(function(e,tp,eg)
    local top=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LIFE,nil):GetFirst()
    if not top then return end
    Duel.ConfirmCards(tp,top)
    if Duel.SelectYesNo(tp) and Duel.SendToTrash(top,REASON_EFFECT)>0 then
      local d=Duel.GetDecktopGroup(1-tp,1)
      if d:GetCount()>0 then Duel.SendToLife(d) end
    end
  end)
  c:RegisterEffect(e2)
end
