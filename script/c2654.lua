-- WX13-083 幻獣　メジロ
-- 【出】《緑》：あなたのデッキから《幻獣　ウグイス》１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{G}")
  e1:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsCardName(2650) end,1)
  end)
  c:RegisterEffect(e1)
end
