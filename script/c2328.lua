-- WX09-001 開かれし極門　ウトゥルス
-- 【グロウ】あなたのルリグデッキから＜タウィル＞か＜ウムル＞のルリグ１枚をあなたのセンタールリグの下に置く
-- 【出】：あなたのトラッシュから白か黒のシグニを合計２枚まで対象とし、それらを手札に加える。
-- 【起】《アタックフェイズアイコン》エクシード５：あなたのすべてのシグニを場からトラッシュに置く。その後、あなたのトラッシュから＜天使＞か＜古代兵器＞のシグニを合計３枚まで対象とし、それらを場に出す。
local s,id=GetID()
function s.initial_effect(c)
  -- 【グロウ】 루리그 덱의 ＜タウィル＞나 ＜ウムル＞를 센터 아래에
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetCode(EFFECT_GROW_PROC)
  e0:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_LRIG) and (x:IsLrigType(LRIG_TAWIL) or x:IsLrigType(LRIG_UMR)) end,tp,LOCATION_LDECK,0,e:GetHandler())
    if chk==0 then return g:GetCount()>0 end
    Duel.PutUnder(Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst(),Duel.SelectCards(tp,g,1,1))
  end)
  c:RegisterEffect(e0)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsColor(COLOR_WHITE) or x:IsColor(COLOR_BLACK)) end,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_LRIG)
  e2:SetExceedCost(5)
  e2:SetTiming(TIMING_ATTACK)
  -- 시그니가 없어도 「その後」는 한다(FAQ 4)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    local t=Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end)(x) or (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KODAIHEIKI)) end)(x) end,tp,LOCATION_TRASH,0,0,3,nil)
    for x in t:Iter() do Duel.PutOnField(x,tp) end
  end)
  c:RegisterEffect(e2)
end
