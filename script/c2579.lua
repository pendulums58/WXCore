-- WX12-054 コードアート　†Ｊ・Ｖ†
-- 【出】：あなたのデッキの上からカードを３枚トラッシュに置く。この方法でトラッシュに置いたカードの中にスペルがある場合、カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    if g:Filter(function(x) return x:IsLocation(LOCATION_TRASH) and x:IsType(TYPE_SPELL) end,nil):GetCount()>0 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
end
