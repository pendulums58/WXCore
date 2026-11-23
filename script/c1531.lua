-- WDK-F03-01 夜明の巫女　タマヨリヒメ
-- 【常】：あなたの場に《燃盛　遊月・鍵》がいるかぎり、このルリグは【ダブルクラッシュ】を得る。
-- 【出】：あなたは手札を好きな枚数捨てる。この方法でカードを１枚以上捨てた場合、捨てたカード１枚につきあなたのデッキから＜遊具＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- 【起】《ターン１回》《メインフェイズアイコン》《アタックフェイズアイコン》《白×0》：あなたのデッキの一番上を見る。
local s,id=GetID()
local KEY=1534  -- 燃盛　遊月・鍵
function s.initial_effect(c)
  -- [の間] 【常】 키가 장에 있는 동안
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_DOUBLE_CRUSH)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCondition(s.keycon)
  c:RegisterEffect(e1)
  -- 코스트가 없는 【出】은 반드시 발동(FAQ 1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(s.searchop)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e3:SetCountLimit(1)
  e3:SetOperation(s.lookop)
  c:RegisterEffect(e3)
end
function s.keycon(e)
  local key=Duel.GetMatchingGroup(function(k) return k:GetCode()==KEY end,e:GetHandlerPlayer(),LOCATION_KEY,0,nil)
  return key:GetCount()>0
end
function s.toy(c) return c:IsSigni() and c:IsClass(0,RACE_YUGU) end
-- 0장 버리면 찾지도 섞지도 않는다(FAQ 2). 찾을 때는 덱을 전부 보고, 다 찾지 않아도 된다(용어집: 探す)
function s.searchop(e,tp)
  local hand=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
  if hand:GetCount()==0 then return end
  local n=Duel.SendToTrash(Duel.SelectDiscard(tp,0,hand:GetCount()),REASON_EFFECT+REASON_DISCARD)
  if n==0 then return end
  Duel.ConfirmCards(tp,Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil))
  local g=Duel.SelectCards(tp,Duel.GetMatchingGroup(s.toy,tp,LOCATION_MDECK,0,nil),0,n)
  if g:GetCount()>0 then
    Duel.RevealCards(g)
    Duel.SendToHand(g)
  end
  Duel.SendToDeckShuffle(Group.CreateGroup(),tp)
end
-- 본 카드는 상대에게 보이지 않고 그대로 덱 위에 뒷면으로(FAQ 3)
function s.lookop(e,tp)
  Duel.ConfirmCards(tp,Duel.GetDecktopGroup(tp,1))
end
