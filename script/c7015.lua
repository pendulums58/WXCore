-- WXK10-041 炎魔の不正　ベリアル
-- 【自】《ビートアイコン》［レベル１～４が各１枚以上］：あなたのアタックフェイズ開始時、【エナチャージ１】をする。
-- 【自】《ビートアイコン》［同じレベルが４枚以上］：このシグニがアタックしたとき、対戦相手のすべてのシグニをバニッシュする。
-- 【出】《ビートアイコン》［４枚以下］《炎魔の不正　ベリアル》以外のシグニ１体を【ビート】にする：カードを１枚引く。
-- ライフバースト：手札を１枚捨てる。対象の対戦相手のシグニ１体をバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp and aux.BeatCon(aux.BeatLevels)(e) end)
  e1:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetCondition(aux.BeatCon(function(g) for lv=1,4 do if g:Filter(function(x) return x:IsSigni() and x:GetLevel()==lv end,nil):GetCount()>=4 then return true end end return false end))
  e2:SetOperation(function(e,tp,eg)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetCondition(aux.BeatCon(function(g) return g:GetCount()<=4 end))
  e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and not x:IsCardName(id) end,tp,LOCATION_SZONE,0,nil)
    if chk==0 then return g:GetCount()>=1 end
    Duel.Beat(Duel.SelectCards(tp,g,1,1),REASON_COST)
  end)
  e3:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e3)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    aux.Discard(tp,1)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e9)
end
