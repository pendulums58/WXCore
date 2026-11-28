-- WXK08-048 轟書　エノキアン
-- 【常】：あなたのアタックフェイズの間、このシグニはこのカードの下にあるレベル３以下の黒の＜ウェポン＞のシグニの【自】能力を得る。
-- 【起】《ターン１回》《黒》：対象のあなたのトラッシュからシグニ１枚を対象のあなたの＜ウェポン＞のシグニ１体の下に置く。
local s,id=GetID()
function s.initial_effect(c)
  -- 【常】「下にあるレベル３以下の黒の＜ウェポン＞のシグニの【自】能力を得る」는 아직
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetEnaCost("{B}")
  e1:SetOperation(function(e,tp,eg)
    local x=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    local host=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_WEAPON) end,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    if x and host then Duel.PutUnder(host,x) end
  end)
  c:RegisterEffect(e1)
end
