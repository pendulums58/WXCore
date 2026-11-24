-- WD23-018-E 幻水　シロナクジ
-- 【常】：あなたの他の＜水獣＞のシグニ１体が対戦相手の効果によって場を離れる場合、代わりにターン終了時まで、このシグニのパワーを－6000してもよい。
-- ライフバースト：対戦相手のシグニ１体を対象とし、手札から好きな枚数の＜水獣＞のシグニを公開する。ターン終了時まで、それのパワーをこの方法で公開したシグニ１枚につき－3000する。
local s,id=GetID()
s.suiju=aux.ClassFilter(0,RACE_SUIJU)  -- ＜水獣＞のシグニ
function s.initial_effect(c)
  -- [の間] 【常】 배틀·룰 처리는 아니다(FAQ 3·4). 자신이 같이 떠나도, 파워가 0이어도 쓸 수 있다(FAQ 5·8)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_LEAVE_GUARD)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return s.suiju(x) end)
  e1:SetValue(-6000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local n=aux.RevealFromHand(tp,s.suiju):GetCount()
    local tc=Duel.GetFirstTarget()
    if n>0 and tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-3000*n) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e2)
end
