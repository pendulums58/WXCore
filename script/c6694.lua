-- WXK06-079 幻竜　ドラゾン
-- 【起】《黒》《ダウン》：あなたのデッキの一番上のカードをトラッシュに置く。それが＜龍獣＞のシグニの場合、対戦相手の手札を１枚見ないで選び、捨てさせる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetEnaCost("{B}")
  e1:SetCost(aux.SelfDownCost)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,1)
    local x=g:GetFirst()
    if not x then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    if (function(x) return x:IsSigni() and x:IsClass(0,RACE_RYUJU) end)(x) then
      local h=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
      if h:GetCount()>0 then Duel.SendToTrash(Duel.SelectCards(tp,h,1,1),REASON_EFFECT+REASON_DISCARD) end
    end
  end)
  c:RegisterEffect(e1)
end
