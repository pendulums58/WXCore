-- WX08-049 羅星　コロカロ
-- 【常】：あなたの場に《羅星　アルシャ》か《羅星　ディアデム》があるかぎり、このシグニの基本パワーは8000になる。
-- 【出】《白》：あなたのデッキから《羅星　ディアデム》を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,8000,function(e) return Duel.GetMatchingGroup(function(x) return x:IsCardName(2297) or x:IsCardName(2280) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0 end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{W}")
  e1:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsCardName(2280) end,1)
  end)
  c:RegisterEffect(e1)
end
