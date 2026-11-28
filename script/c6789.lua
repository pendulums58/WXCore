-- WXK07-091 羅星　ラグーネ
-- 【出】《黒》：あなたのデッキの一番上を公開する。その後、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーをこの方法で公開されたシグニのレベル１につき－1000する。公開したカードをトラッシュに置く。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{B}")
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,1)
    local x=g:GetFirst()
    if not x then return end
    Duel.RevealCards(g)
    local n=x:IsSigni() and x:GetLevel() or 0
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc and n>0 then aux.AddPower(e,tc,-1000*n) end
    Duel.SendToTrash(g,REASON_EFFECT)
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e9)
end
