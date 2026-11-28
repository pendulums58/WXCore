-- WXK05-001 再会の巫女　マユ
-- 【グロウ】あなたの場にある《一途の巫女　ユキ》をあなたのセンタールリグの下に置く
-- 【出】：対戦相手は、自分の手札を２枚捨てるか、自分のエナゾーンから対象のカードを３枚トラッシュに置かないかぎり、対象の自分のシグニ１体を場からトラッシュに置く。
-- 【起】リスタート《コインアイコン》エクシード４：あなたはこのターンの次に、追加の１ターンを得る。この方法で追加されたターンのメインフェイズの間、あなたは手札からシグニを場に出せない。
local s,id=GetID()
function s.initial_effect(c)
  -- 【グロウ】 장의 《一途の巫女　ユキ》를 센터 아래에
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetCode(EFFECT_GROW_PROC)
  e0:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsCardName(6293) end,tp,LOCATION_KEY,0,nil)
    if chk==0 then return g:GetCount()>0 end
    Duel.PutUnder(Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst(),Duel.SelectCards(tp,g,1,1))
  end)
  c:RegisterEffect(e0)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    local p=1-tp
    local h=Duel.GetMatchingGroup(nil,p,LOCATION_HAND,0,nil)
    local en=Duel.GetMatchingGroup(nil,p,LOCATION_ENA,0,nil)
    local m=Duel.SelectOption(p,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
    if m==0 and h:GetCount()>=2 then Duel.SendToTrash(Duel.SelectCards(p,h,2,2),REASON_EFFECT+REASON_DISCARD) return end
    if m==1 and en:GetCount()>=3 then Duel.SendToTrash(Duel.SelectTarget(p,nil,p,LOCATION_ENA,0,3,3,nil),REASON_EFFECT) return end
    local x=Duel.SelectTarget(p,Card.IsSigni,p,LOCATION_SZONE,0,1,1,nil):GetFirst()
    if x then Duel.SendToTrash(x,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCoinCost(1)
  e2:SetExceedCost(4)
  e2:SetOperation(function(e,tp,eg)
    Duel.ExtraTurn(tp)
    -- 추가된 턴의 메인 페이즈 동안 패에서 시그니를 낼 수 없다
    local now=Duel.GetTurnCount()
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SIGNI_LIMIT)
    e1:SetTargetRange(1,0)
    e1:SetValue(0)
    e1:SetCondition(function() return Duel.GetTurnCount()==now+1 and Duel.GetPhase()==PHASE_MAIN end)
    e1:SetReset(RESET_PHASE+PHASE_END,2)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e2)
end
