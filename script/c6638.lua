-- WXK06-023 ＧＦ　ハウス
-- 【常】：このシグニは中央のシグニゾーンにあるかぎり、「【自】：あなたのターン終了時、このターンにシグニが４回以上アタックしていた場合、対戦相手にダメージを与える。」を得る。
-- 【自】：このシグニがアタックしたとき、このシグニを場から手札に戻してもよい。そうした場合、あなたの手札から《ＧＦ　ハウス》以外のレベル４のシグニ１枚を場に出す。そのシグニの【出】能力は発動しない。
-- ライフバースト：手札を１枚捨てる。対象の対戦相手のシグニ１体をトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Stringid(id,0))
  g:SetCode(EVENT_TURN_END)
  g:SetRange(LOCATION_SZONE)
  g:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp and Duel.GetAttackCount()>=4 end)
  g:SetOperation(function(e,tp) Duel.Damage(1-tp) end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():IsInZone("signi_center") end)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    if not (h:IsLocation(LOCATION_SZONE) and Duel.SelectYesNo(tp)) or Duel.SendToHand(h)==0 then return end
    local g=Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_EICHI) end)(x) and x:GetLevel()==4 and not x:IsCardName(id) end,tp,LOCATION_HAND,0,nil)
    if g:GetCount()>0 then Duel.PutOnField(Duel.SelectCards(tp,g,1,1):GetFirst(),tp,true) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    aux.Discard(tp,1)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e9)
end
