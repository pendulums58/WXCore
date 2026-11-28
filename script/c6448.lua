-- WXK03-074 円卓の獅士　ユーウェイン
-- 【出】《黒》：あなたのデッキの上からカードを５枚トラッシュに置く。その後、この方法でトラッシュに置かれた＜武勇＞のシグニの枚数と同じレベルを持つ対戦相手のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{B}")
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,5)
    if g:GetCount()==0 then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    local n=g:Filter(function(x) return x:IsLocation(LOCATION_TRASH) and x:IsSigni() and x:IsClass(0,RACE_BUYU) end,nil):GetCount()
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()==n end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
end
