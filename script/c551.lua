-- SP27-006 疾走の魔鹿　フルフル（セレクターズパック vol.16）
-- 【常】：あなたのトラッシュにカードが２５枚以上あるかぎり、このシグニは【アサシン】を得る。
-- 【自】：このカードが手札かデッキからトラッシュに置かれたとき、あなたのデッキの上からカードを３枚トラッシュに置いてもよい。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_ASSASSIN)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_TRASH,0,nil):GetCount()>=25 end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_TO_TRASH)
  e2:SetCondition(function(e) local h=e:GetHandler() return h:IsPreviousLocation(LOCATION_HAND) or h:IsPreviousLocation(LOCATION_MDECK) end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()>0 and Duel.SelectYesNo(tp) then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
end
