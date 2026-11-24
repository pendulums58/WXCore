-- WDK10-012 幻竜　ペイモン
-- 【出】《黒》：あなたのデッキの上からカードを４枚トラッシュに置く。その後、あなたのトラッシュから＜龍獣＞のシグニ１枚を対象とし、それを手札に加える。
local s,id=GetID()
s.ryu=aux.ClassFilter(0,RACE_RYUJU)  -- ＜龍獣＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{B}")
  -- 4장이 안 돼도 고른다. 리프레시는 처리한 뒤(FAQ 1)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,4)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    local tc=Duel.SelectTarget(tp,s.ryu,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if tc then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
end
