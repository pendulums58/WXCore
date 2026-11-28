-- WDK14-009 奏楽の鍵主　ウムル
-- 【出】：あなたのデッキの上からカードを４枚トラッシュに置く。その後、あなたのトラッシュからシグニ１枚を対象とし、それを場に出す。あなたのセンタールリグが＜タウィル＞の場合、追加でシグニ１枚を対象とし、それを場に出す。
-- 【起】《アタックフェイズアイコン》このキーを場からルリグトラッシュに置く：対戦相手のシグニ１体を対象とし、それをダウンする。カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  -- 덱 위 4장을 트래시에 둔 뒤에 대상을 고른다(FAQ 2). 레벨·리미트는 지킨다(FAQ 3)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,4)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    local n=(lc and lc:IsLrigType(LRIG_TAWIL)) and 2 or 1
    local t=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,n,nil)
    for tc in t:Iter() do
      if tc:IsLocation(LOCATION_TRASH) then Duel.PutOnField(tc,tp) end
    end
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
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  -- 다운하지 못해도 뽑는다(FAQ 4)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Down(tc) end
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
