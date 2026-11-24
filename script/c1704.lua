-- WDK10-017 幻竜　スクブス
-- 【出】：あなたのデッキの上からカードを３枚トラッシュに置く。この方法で＜龍獣＞のシグニが３枚トラッシュに置かれた場合、各プレイヤーは手札を１枚捨てる。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
s.ryu=aux.ClassFilter(0,RACE_RYUJU)  -- ＜龍獣＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    -- 덱이 2장 이하면 3장이 되지 않는다(FAQ 1)
    if g:Filter(function(x) return x:IsLocation(LOCATION_TRASH) and s.ryu(x) end,nil):GetCount()<3 then return end
    aux.Discard(tp,1)
    aux.Discard(1-tp,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
