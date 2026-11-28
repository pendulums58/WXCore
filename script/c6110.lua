-- WXEX1-76 強欲な主　ママハハ
-- 【常】：あなたのトラッシュにカードが１５枚以上あるかぎり、このシグニのパワーは＋6000され、このシグニは【ランサー】を得る。
-- 【常】：あなたのターンの間、あなたのトラッシュにカードが３０枚以上あるかぎり、このシグニは「【常】：バニッシュされない。」を得る。
-- 【出】：各プレイヤーは自分のデッキの上からカードを３枚トラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_TRASH,0,nil):GetCount()>=15 end)
  e1:SetValue(6000)
  c:RegisterEffect(e1)
  local e1b=Effect.CreateEffect(c)
  e1b:SetType(EFFECT_TYPE_SINGLE)
  e1b:SetCode(EFFECT_LANCER)
  e1b:SetRange(LOCATION_SZONE)
  e1b:SetCondition(function(e) return Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_TRASH,0,nil):GetCount()>=15 end)
  c:RegisterEffect(e1b)
  -- [の間] 【常】
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_CANNOT_BANISH)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e)
    local tp=e:GetHandlerPlayer()
    return Duel.GetTurnPlayer()==tp and Duel.GetMatchingGroup(nil,tp,LOCATION_TRASH,0,nil):GetCount()>=30
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetOperation(function(e,tp)
    local g1=Duel.GetDecktopGroup(tp,3)
    local g2=Duel.GetDecktopGroup(1-tp,3)
    if g1:GetCount()>0 then Duel.SendToTrash(g1,REASON_EFFECT) end
    if g2:GetCount()>0 then Duel.SendToTrash(g2,REASON_EFFECT) end
  end)
  c:RegisterEffect(e3)
end
