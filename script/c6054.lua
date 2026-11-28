-- WXEX1-20 エボルブ/メイデン　イオナ
-- 【出】：あなたのデッキの上からカードを３枚公開する。その中から白か黒のシグニを合計２枚まで手札に加え、残りをトラッシュに置く。
-- 【起】《アタックフェイズアイコン》《コインアイコン》《コインアイコン》：あなたのルリグデッキから＜イオナ＞１枚をこのルリグの上に置く。（【グロウ】やグロウコストは無視される）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local n=aux.RevealCount(tp,3)
    local g=Duel.GetDecktopGroup(tp,n)
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local pick=Duel.SelectCards(tp,g:Filter(function(x) return x:IsSigni() and (x:IsColor(COLOR_WHITE) or x:IsColor(COLOR_BLACK)) end,nil),0,2)
    if pick:GetCount()>0 then Duel.SendToHand(pick) end
    local rest=g:Filter(function(x) return not pick:IsContains(x) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetTiming(TIMING_ATTACK)
  e2:SetCoinCost(2)
  e2:SetOperation(function(e,tp)
    local pool=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_LRIG) and x:IsLrigType(LRIG_IONA) end,tp,LOCATION_LDECK,0,nil)
    local tc=Duel.SelectCards(tp,pool,1,1):GetFirst()
    if tc then Duel.GrowByEffect(tc,tp) end
  end)
  c:RegisterEffect(e2)
end
