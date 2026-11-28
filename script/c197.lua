-- PR-322 白亜の鍵主　ウルトゥム（セレクターズパック ウムル&タウィル 4パック購入特典）
-- 【起】《ターン１回》《黒×0》：対戦相手のシグニ１体を対象とし、あなたのトラッシュから黒の＜天使＞のシグニ１枚と黒の＜古代兵器＞のシグニ１枚を好きな順番でデッキの一番下に置く。そうした場合、それをトラッシュに置く。
-- 【起】《アタックフェイズアイコン》エクシード２：あなたのトラッシュから黒のシグニ１枚を対象とし、それを場に出すかあなたの手札から黒のシグニ１枚を場に出す。この方法で場に出たシグニの【出】能力は発動しない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  -- 대상이 없어도 쓸 수 있다(FAQ 2·3)
  e1:SetOperation(function(e,tp)
    local a=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) and x:IsClass(0,RACE_TENSHI) end,tp,LOCATION_TRASH,0,nil),1,1)
    local b=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) and x:IsClass(0,RACE_KODAIHEIKI) end,tp,LOCATION_TRASH,0,a:GetFirst()),1,1)
    if a:GetCount()==0 or b:GetCount()==0 then return end
    a:Merge(b)
    Duel.SendToDeckBottom(Duel.SelectOrder(tp,a),false)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetTiming(TIMING_ATTACK)
  e2:SetExceedCost(2)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,tp,LOCATION_TRASH+LOCATION_HAND,0,nil)
    local tc=Duel.SelectCards(tp,g,0,1):GetFirst()
    if tc then Duel.PutOnField(tc,tp,true) end
  end)
  c:RegisterEffect(e2)
end
