-- WD13-011 原槍　アークエナジェ
-- 【常】：対戦相手は自分のエナフェイズをスキップする。
-- 【常】：あなたの場に《原槍 エナジェ》があるかぎり、対戦相手のシグニがバニッシュされる場合、エナゾーンに置かれる代わりにトラッシュに置かれる。
-- 【出】《白》《白》《白》：あなたのデッキから＜アーム＞のシグニを２枚まで探して場に出し、デッキをシャッフルする。
-- ライフバースト：あなたのデッキからカード１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_SKIP_ENA)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(0,1)
  c:RegisterEffect(e1)
  -- [の間] 【常】 1236 = 《原槍　エナジェ》
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_BANISH_TO_TRASH)
  e2:SetRange(LOCATION_SZONE)
  e2:SetTargetRange(0,LOCATION_SZONE)
  e2:SetCondition(function(e)
    return Duel.GetMatchingGroup(function(x) return x:GetCode()==1236 end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0
  end)
  c:RegisterEffect(e2)
  -- 놓을 존이 없어도 쓸 수 있다(FAQ 2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetEnaCost("{W}{W}{W}")
  e3:SetOperation(function(e,tp)
    Duel.ConfirmCards(tp,Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil))
    local g=Duel.SelectCards(tp,Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_ARM),tp,LOCATION_MDECK,0,nil),0,2)
    for tc in g:Iter() do Duel.PutOnField(tc,tp) end
    Duel.SendToDeckShuffle(Group.CreateGroup(),tp)
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetOperation(function(e,tp) aux.SearchToHand(tp,nil,1) end)
  c:RegisterEffect(e4)
end
