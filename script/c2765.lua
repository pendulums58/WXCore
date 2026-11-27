-- WX15-031 幻怪姫　ヌラリ
-- 【レイヤー】あなたの＜怪異＞のシグニは《レイヤーアイコン》の能力を得る
-- 《レイヤーアイコン》【常】：このシグニは対戦相手のコストの合計が５以上の、アーツとスペルの効果を受けない。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それを手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【レイヤー】 이 시그니가 있으면 ＜怪異＞ 시그니(자신 포함)가 《レイヤーアイコン》 능력을 얻는다
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KAII)) end)(x) end)
  e1:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and (sc:IsType(TYPE_ARTS) or sc:IsType(TYPE_SPELL)) and sc:GetCostTotal()>=5 end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e2)
end
