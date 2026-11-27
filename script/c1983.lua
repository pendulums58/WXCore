-- WX03-034 コードアンチ　コスタリク
-- 【出】：対戦相手のシグニ１体を対象とし、このシグニがトラッシュから場に出た場合、ターン終了時まで、それのパワーを－5000する。
-- （パワーが０以下のシグニはルールによってバニッシュされる）
-- ライフバースト：手札から＜古代兵器＞のシグニを１枚捨てる。そうした場合、カードを２枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if e:GetHandler():IsPreviousLocation(LOCATION_TRASH) and tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-5000) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    -- 패는 비공개라 버리지 않아도 된다
    local g=Duel.SelectDiscard(tp,0,1,function(x) return x:IsSigni() and (x:IsClass(0,RACE_KODAIHEIKI)) end)
    if g:GetCount()>0 and Duel.SendToTrash(g,REASON_EFFECT+REASON_DISCARD)>0 then Duel.Draw(tp,2) end
  end)
  c:RegisterEffect(e2)
end
