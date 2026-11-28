-- SPK01-01 コードライド　シマカゼ（パーティーパックVol.1）
-- 【起】《ターン１回》《赤》：ターン終了時まで、対象のあなたのセンタールリグ１体は対象のあなたの＜乗機＞のシグニ１体に乗る。（すでに他のシグニに乗っている場合は乗り換える）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetEnaCost("{R}")
  -- 자기 자신에도, 이미 ドライブ状態여도 된다(FAQ 1·2)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_JOUKI) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Ride(tc) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e1)
end
