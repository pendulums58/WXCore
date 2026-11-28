-- WXEX1-47 コードアンチ　ナイトゴン
-- 【自】：あなたのアタックフェイズ開始時、あなたのデッキの上からカードを７枚トラッシュに置く。その後、この方法でトラッシュに＜古代兵器＞のシグニが５枚以上置かれた場合、対戦相手のシグニ１体を対象とし、それをバニッシュし、対戦相手のライフクロス１枚をクラッシュする。
-- 【出】：あなたのトラッシュからそれぞれレベルの異なる＜古代兵器＞のシグニ４枚を好きな順番でデッキの一番下に置く。そうした場合、カードを１枚引く。
-- ライフバースト：あなたのトラッシュから＜古代兵器＞のシグニ１枚を対象とし、それを手札に加えるか場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,7)
    if g:GetCount()==0 then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    if g:Filter(function(x) return x:IsLocation(LOCATION_TRASH) and x:IsSigni() and x:IsClass(0,RACE_KODAIHEIKI) end,nil):GetCount()>=5 then
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.Banish(tc) end
      Duel.Crush(1-tp,1)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local pool=Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_KODAIHEIKI),tp,LOCATION_TRASH,0,nil)
    Duel.SetSelectCheck(aux.DistinctLevels)
    local pick=Duel.SelectCards(tp,pool,4,4)
    if pick:GetCount()==4 then
      Duel.SendToDeckBottom(pick,false)
      Duel.Draw(tp,1)
    end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,aux.ClassFilter(0,RACE_KODAIHEIKI),tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e9:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then Duel.SendToHand(tc) else Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e9)
end
