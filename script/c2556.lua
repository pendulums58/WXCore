-- WX12-030 コードアート　Ｐ・Ｓ・Ｍ
-- 【出】手札からスペルを１枚捨てる：あなたのデッキから、この方法で捨てたスペルと共通する色を持つスペル１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_SPELL) end,tp,LOCATION_HAND,0,nil)
    if chk==0 then return g:GetCount()>0 end
    local x=Duel.SelectCards(tp,g,1,1):GetFirst()
    e:SetLabel(x:GetColor())
    Duel.SendToTrash(x,REASON_COST+REASON_DISCARD)
  end)
  e1:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsType(TYPE_SPELL) and x:GetColor()&e:GetLabel()~=0 end,1)
  end)
  c:RegisterEffect(e1)
end
