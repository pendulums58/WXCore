-- WX13-031 弩中砲　グスタフト
-- 《クロスアイコン》《轟左砲　ドーラ》の右　かつ　《轟右砲　ドスラフ》の左
-- 【常】：このシグニがバニッシュされる場合、代わりにバニッシュされず、ターン終了時まで、この能力を失う。
-- 【クロス自】《ターン１回》：このシグニが《ヘブン》したとき、あなたのすべてのシグニをアップする。
-- ライフバースト：あなたのトラッシュから《クロスアイコン》を持つシグニを２枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  -- 「《ドーラ》の右　かつ　《ドスラフ》の左」(3체 크로스)는 아직: 둘 중 한쪽으로 근사
  aux.AddCross(c,1412,CROSS_RIGHT)
  aux.AddCross(c,1413,CROSS_LEFT)
  -- 【常】 「バニッシュされる場合、代わりに…この能力を失う」는 아직(근사 없음)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,2))
  e1:SetCode(EVENT_HEAVEN)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetOperation(function(e,tp)
    Duel.Up(Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil))
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:HasCrossIcon() end,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e2)
end
