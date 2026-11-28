-- WDK13-001 ミュウ＝バタフライ
-- 【出】：あなたのトラッシュから＜宇宙＞のシグニを２枚まで対象とし、それらを手札に加える。
-- 【起】《ターン１回》手札から＜宇宙＞のシグニを１枚捨てる：以下の２つから１つを選ぶ。
-- ①対戦相手のレベル２以下のシグニ１体を対象とし、それをバニッシュする。
-- ②対戦相手のトラッシュにあるカード１枚を対象とし、それをゲームから除外する。
-- 【起】《ゲーム１回》サイレント《コインアイコン》《コインアイコン》：対戦相手のシグニゾーンにある表向きのすべてのカードをトラッシュに置く。
local s,id=GetID()
s.space=aux.ClassFilter(0,RACE_UCHU)  -- ＜宇宙＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  -- 0~2장(FAQ 1)
  e1:SetOperation(function(e,tp)
    local g=Duel.SelectTarget(tp,s.space,tp,LOCATION_TRASH,0,0,2,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetCost(aux.DiscardCost(1,s.space))
  e2:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==0 then
      Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=2 end,tp,0,LOCATION_SZONE,1,1,nil)
    else
      Duel.SelectTarget(tp,nil,tp,0,LOCATION_TRASH,1,1,nil)
    end
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if e:GetLabel()==0 then Duel.Banish(tc) else Duel.Exclude(tc) end end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(1,true)
  e3:SetCoinCost(2)
  -- 【ウィルス】·【ゲート】은 카드가 아니고, 뒷면 【チャーム】은 룰 처리로 트래시(FAQ 2·3)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e3)
end
