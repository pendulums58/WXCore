-- WX10-015 フラッシュ・バック
-- あなたのライフクロスの一番上を見る。それをトラッシュに置いてもよい。そうした場合、あなたのデッキの一番上のカードをライフクロスに加える。
-- 対戦相手のライフクロスの一番上を見る。それをトラッシュに置いてもよい。そうした場合、対戦相手のデッキの一番上のカードをライフクロスに加える。
-- 【自】：あなたか対戦相手のライフバーストが発動したとき、《青》を支払ってもよい。そうした場合、このカードをルリグトラッシュからルリグデッキに戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    for _,p in ipairs({tp,1-tp}) do
      local top=Duel.GetMatchingGroup(nil,p,LOCATION_LIFE,0,nil):GetFirst()
      if top then
        Duel.ConfirmCards(tp,top)
        if Duel.SelectYesNo(tp) and Duel.SendToTrash(top,REASON_EFFECT)>0 then
          local d=Duel.GetDecktopGroup(p,1)
          if d:GetCount()>0 then Duel.SendToLife(d) end
        end
      end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_LIFEBURST)
  e2:SetRange(LOCATION_LTRASH)
  e2:SetOperation(function(e,tp)
    if not (Duel.CanPayEna(tp,"{U}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{U}"),REASON_COST)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_LTRASH) then Duel.SendToLrigDeck(h) end
  end)
  c:RegisterEffect(e2)
end
