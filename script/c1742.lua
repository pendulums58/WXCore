-- WDK13-009 聖援の使者 サシェ
-- 【起】《ターン１回》《無》：あなたのデッキからあなたのセンタールリグと共通する色を持つシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- 【起】《アタックフェイズアイコン》このキーを場からルリグトラッシュに置く：あなたのデッキから＜宇宙＞のシグニ１枚を探して場に出し、デッキをシャッフルする。そのシグニの【出】能力は発動しない。
local s,id=GetID()
s.space=aux.ClassFilter(0,RACE_UCHU)  -- ＜宇宙＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_KEY)
  e1:SetCountLimit(1)
  e1:SetEnaCost("{C}")
  -- 무색 루리그·【マルチエナ】는 공통된 색이 아니다(FAQ 1)
  e1:SetOperation(function(e,tp)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    local col=lc and lc:GetColor() or 0
    local g=aux.Search(tp,function(x) return x:IsSigni() and x:GetColor()&col~=0 end,1)
    if g:GetCount()>0 then
      Duel.RevealCards(g)
      Duel.SendToHand(g)
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_KEY)
  e2:SetTiming(TIMING_ATTACK)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) end
    Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
  end)
  -- 레벨·리미트·한정 조건은 지킨다(FAQ 2)
  e2:SetOperation(function(e,tp)
    local sc=aux.Search(tp,function(x) return s.space(x) end,1):GetFirst()
    if sc then Duel.PutOnField(sc,tp,true) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e2)
end
