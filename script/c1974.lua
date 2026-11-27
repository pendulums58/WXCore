-- WX03-023 手剣　カクマル
-- 【常】：あなたの場に《手弾　アヤボン》があるかぎり、このシグニの基本パワーは8000になる。
-- 【出】《赤》《無》：あなたのデッキから《手弾　アヤボン》１枚を探して場に出し、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,8000,function(e) return Duel.GetMatchingGroup(function(x) return x:IsCardName(1977) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0 end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{R}{C}")
  -- 리미트를 넘으면 내지 못한다(FAQ 1)
  e1:SetOperation(function(e,tp)
    local x=aux.Search(tp,function(x) return x:IsCardName(1977) end,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
end
