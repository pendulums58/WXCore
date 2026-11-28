-- WXEX1-38 コードハート　Ａ・Ｃ・Ｒ
-- 【自】：あなたのアタックフェイズ開始時、このターンにあなたがスペルを使用していた場合、対戦相手の手札を１枚見ないで選び、対戦相手はそれをデッキの一番上に置く。
-- 【出】《無》：対戦相手のシグニ１体を対象とし、あなたのトラッシュにスペルが３種類以上ある場合、それをバニッシュする。スペルが５種類以上ある場合、代わりにそれをトラッシュに置く。
-- ライフバースト：あなたのトラッシュから＜電機＞のシグニ１枚とスペル１枚を対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e1:SetOperation(function(e,tp)
    if Duel.GetSpellsUsedCount(tp)==0 then return end
    local tc=Duel.SelectCards(tp,Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil),1,1):GetFirst()
    if tc then Duel.SendToDeckPosition(tc,1) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{C}")
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    local seen={}
    for x in Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_SPELL) end,tp,LOCATION_TRASH,0,nil):Iter() do
      seen[x:GetCode()]=true
    end
    local n=0
    for _ in pairs(seen) do n=n+1 end
    if n>=5 then Duel.SendToTrash(tc,REASON_EFFECT)
    elseif n>=3 then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,aux.ClassFilter(0,RACE_DENKI),tp,LOCATION_TRASH,0,1,1,nil)
    Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_SPELL) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e9:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(Card.IsRelateToEffect,nil,e)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e9)
end
