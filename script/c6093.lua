-- WXEX1-59 幻怪　ヤマンバ
-- 【自】：このシグニがアタックしたとき、あなたの場にあるシグニが持つ《レイヤーアイコン》１つにつき【エナチャージ１】をする。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local n=Duel.GetMatchingGroup(function(x) return x:IsSigni() and aux.HasLayer(x) end,tp,LOCATION_SZONE,0,nil):GetCount()
    if n>0 then Duel.EnaCharge(tp,n) end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e9)
end
