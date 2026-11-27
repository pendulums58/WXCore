-- WX05-005 黒点の巫女　タマヨリヒメ
-- 【グロウ】あなたのトラッシュに黒のカードが１０枚以上ある
-- 【常】：エナゾーン以外の領域にあるシグニは黒になる。
-- 【起】《黒》エナゾーンから黒のカード１枚をトラッシュに置く：対戦相手のシグニ１体を対象とし、それをトラッシュに置く。
-- 【起】《アタックフェイズアイコン》エクシード５：対戦相手の、センタールリグとすべてのシグニをダウンする。
local s,id=GetID()
function s.initial_effect(c)
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetCode(EFFECT_GROW_PROC)
  e0:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetMatchingGroup(function(x) return x:IsColor(COLOR_BLACK) end,tp,LOCATION_TRASH,0,nil):GetCount()>=10 end
  end)
  c:RegisterEffect(e0)
  -- [の間] 【常】 에나 존 외의 시그니를 흑으로 덮어쓴다(FAQ 2·3)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_CHANGE_COLOR)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(LOCATION_SIGNI+LOCATION_CHEER+LOCATION_HAND+LOCATION_MDECK+LOCATION_LIFE+LOCATION_CHECK+LOCATION_TRASH,LOCATION_SIGNI+LOCATION_CHEER+LOCATION_HAND+LOCATION_MDECK+LOCATION_LIFE+LOCATION_CHECK+LOCATION_TRASH)
  e1:SetTarget(function(e,x) return x:IsSigni() end)
  e1:SetValue(COLOR_BLACK)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_LRIG)
  e2:SetEnaCost("{B}")
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsColor(COLOR_BLACK) end,tp,LOCATION_ENA,0,nil)
    if chk==0 then return g:GetCount()>0 end
    Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_COST)
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetRange(LOCATION_LRIG)
  e3:SetExceedCost(5)
  e3:SetTiming(TIMING_ATTACK)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
    local lc=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst()
    if lc then g:AddCard(lc) end
    Duel.Down(g)
  end)
  c:RegisterEffect(e3)
end
