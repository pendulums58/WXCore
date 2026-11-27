-- WX10-067 コードアート　Ｗ・Ｇ・Ｍ
-- 【常】：あなたのトラッシュにスペルが３枚以上あるかぎり、このシグニの基本パワーは12000になる。
-- 【出】《青×0》：あなたのデッキからスペル１枚を探してトラッシュに置き、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,12000,function(e) return Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_SPELL) end,e:GetHandlerPlayer(),LOCATION_TRASH,0,nil):GetCount()>=3 end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local x=aux.Search(tp,function(x) return x:IsType(TYPE_SPELL) end,1):GetFirst()
    if x then Duel.SendToTrash(x,REASON_EFFECT) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
end
