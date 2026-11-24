-- WDK07-E15 コードイート　コロアイス
-- 【出】：あなたのデッキの一番上を公開する。それが＜調理＞のシグニの場合、それをこのシグニの【アクセ】にする。
local s,id=GetID()
s.chouri=aux.ClassFilter(0,RACE_CHOURI)  -- ＜調理＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local h,top=e:GetHandler(),Duel.GetDecktopGroup(tp,1):GetFirst()
    if not top then return end
    Duel.RevealCards(top)
    if s.chouri(top) then Duel.Acce(top,h) end
  end)
  c:RegisterEffect(e1)
end
