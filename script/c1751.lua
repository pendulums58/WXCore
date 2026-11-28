-- WDK14-001 奏でし者　タウィル＝フィーラ
-- 【自】《ビートアイコン》［レベル１～４が各１枚以上］：あなたのアタックフェイズ開始時、カードを１枚引くか【エナチャージ１】をする。
-- 【起】《ターン１回》シグニ１体を【ビート】にする：カードを１枚引く。
-- 【起】《ゲーム１回》《アタックフェイズアイコン》プライマル《コインアイコン》ルリグデッキから赤のアーツ１枚をルリグトラッシュに置く：あなたのトラッシュから＜悪魔＞のシグニを３枚まで対象とし、それらを場に出す。
local s,id=GetID()
s.akuma=aux.ClassFilter(0,RACE_AKUMA)  -- ＜悪魔＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCondition(function(e,tp,eg,ep) return ep==tp and aux.BeatCon(aux.BeatLevels)(e) end)
  e1:SetOperation(function(e,tp)
    if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then Duel.Draw(tp,1) else Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil)
    if chk==0 then return g:GetCount()>0 end
    Duel.Beat(Duel.SelectCards(tp,g,1,1),REASON_COST)
  end)
  -- 영역 지정이 없으면 내 장의 시그니(FAQ 1)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetTiming(TIMING_ATTACK)
  e3:SetCountLimit(1,true)
  e3:SetCoinCost(1)
  e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_ARTS) and x:IsColor(COLOR_RED) end,tp,LOCATION_LDECK,0,nil)
    if chk==0 then return g:GetCount()>0 end
    Duel.SendToLrigTrash(Duel.SelectCards(tp,g,1,1),REASON_COST)
  end)
  -- 빨강을 포함하는 여러 색 아츠도 된다(FAQ 4). 레벨·리미트는 지킨다(FAQ 2)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,s.akuma,tp,LOCATION_TRASH,0,0,3,nil)
  end)
  e3:SetOperation(function(e,tp)
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_TRASH) then Duel.PutOnField(tc,tp) end
    end
  end)
  c:RegisterEffect(e3)
end
