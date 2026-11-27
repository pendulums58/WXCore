-- WX09-029 コードアート　Ｓ・Ｍ・Ｓ
-- 【出】《青》：あなたの場に＜電機＞のシグニが３体ある場合、対戦相手の手札を１枚見ないで選び、捨てさせる。
-- ライフバースト：あなたのデッキから＜電機＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{U}")
  e1:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_DENKI)) end,tp,LOCATION_SZONE,0,nil):GetCount()<3 then return end
    -- 「見ないで選び」
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    if g:GetCount()>0 then Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT+REASON_DISCARD) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_DENKI)) end,1)
  end)
  c:RegisterEffect(e2)
end
