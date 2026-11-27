-- WX02-005 ホワイト・ホープ
-- あなたのデッキからレベル２以下の＜アーム＞か＜ウェポン＞のシグニを合計２枚まで探して場に出し、デッキをシャッフルする。ターン終了時、それらを場からトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local f=function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_ARM) or x:IsClass(0,RACE_WEAPON)) end)(x) and x:IsLevelBetween(0,2) end
    Duel.SetSelectCheck(function(g) return Duel.CanPutAll(g,tp) end)
    local g=aux.Search(tp,f,2)
    local put={}
    for tc in g:Iter() do
      if Duel.PutOnField(tc,tp) then put[#put+1]=tc end
    end
    aux.ShuffleDeck(tp)
    -- 그 객체에 건다. 장을 떠나면 끊긴다(FAQ 3)
    for _,tc in ipairs(put) do
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
      e1:SetDescription(aux.Ability(id,0))
      e1:SetCode(EVENT_TURN_END)
      e1:SetRange(LOCATION_SZONE)
      e1:SetReset(RESET_PHASE+PHASE_END)
      e1:SetOperation(function(e1)
        local h=e1:GetHandler()
        if h:IsLocation(LOCATION_SZONE) then Duel.SendToTrash(h,REASON_EFFECT) end
      end)
      tc:RegisterEffect(e1)
    end
  end)
  c:RegisterEffect(e1)
end
