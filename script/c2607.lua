-- WX13-029 羅星宙姫　ノーザンセブン
-- 【自】：あなたのアタックフェイズ開始時、以下の４つから１つを選ぶ。
-- ①このターン、あなたのシグニはバニッシュされない。
-- ②このターン、あなたのシグニは場から手札に戻らない。
-- ③このターン、あなたのシグニは新たに能力を得られない。
-- ④このターン、あなたのシグニは対戦相手の効果によってダウンしない。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e1:SetOperation(function(e,tp)
    local m=Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))[1]
    -- ③ 「新たに能力を得られない」는 아직(근사 없음)
    local code=({EFFECT_CANNOT_BANISH,EFFECT_NO_BOUNCE,nil,EFFECT_NO_DOWN_BY_OPP})[m+1]
    if not code then return end
    -- [の間] 「このターン」
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(code)
    e1:SetTargetRange(LOCATION_SZONE,0)
    e1:SetTarget(function(e,x) return x:IsSigni() end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
end
