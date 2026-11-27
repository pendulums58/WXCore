-- WX01-059 出弓　ボウ
-- 【出】：あなたのデッキの一番上を見る。それがレベル１のシグニであなたの場に他のシグニがない場合、それを場に出してもよい。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    -- 덱 위를 보고 맞으면 내도 된다. 내면 그 시그니의 【出】도 발동한다(FAQ 2·4)
    local top=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not top then return end
    Duel.ConfirmCards(tp,top)
    if not ((function(x) return x:IsSigni() and x:GetLevel()==1 end)(top) and Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,e:GetHandler()):GetCount()==0) then return end
    if Duel.SelectYesNo(tp) then Duel.PutOnField(top,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
