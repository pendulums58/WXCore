-- WD23-022-E 幻水姫　ナマコズ
-- 【常】：このシグニのパワーはあなたのライフクロス１枚につき－2000される。
-- 【常】：あなたのライフクロスが０枚であるかぎり、このシグニはバニッシュされない。
-- 【出】：あなたのライフクロスの一番上を見る。その後、それをクラッシュしてもよい。
-- ライフバースト：あなたのライフクロスが０枚の場合、デッキの一番上のカードをライフクロスに加える。カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetValue(function(e) return -2000*Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_LIFE,0,nil):GetCount() end)
  c:RegisterEffect(e1)
  -- [の間] 【常】
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_CANNOT_BANISH)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e) return Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_LIFE,0,nil):GetCount()==0 end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetLifetopGroup(tp,1)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    if Duel.SelectYesNo(tp) then Duel.Crush(tp,1) end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()==0 then Duel.SendToLife(Duel.GetDecktopGroup(tp,1)) end
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e4)
end
