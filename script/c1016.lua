-- SPK01-11 コードイート　ラズベリー（パーティーパックVol.4）
-- 【自】：このカードが【アクセ】としてシグニに付いたとき、以下の３つから１つを選ぶ。
-- ①「【常】：このシグニは対戦相手の効果によってダウンしない。」
-- ②「【常】：このシグニは対戦相手の効果によって手札に戻らない。」
-- ③「【自】：このシグニがアタックしたとき、カードを１枚引く。」
-- 【常】：これにアクセされているシグニは上の【自】能力で選んだ能力を得る。
local s,id=GetID()
function s.initial_effect(c)
  local chosen={}  -- 장을 떠나지 않는 동안 고른 것은 쌓인다(FAQ 4)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ACCE)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if not (h:IsPreviousLocation(LOCATION_SZONE) or h:IsPreviousLocation(LOCATION_ACCE)) then chosen={} end
    chosen[Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))]=true
  end)
  c:RegisterEffect(e1)
  local function host(e,x) return x==e:GetHandler():GetAcceHost() end
  -- [の間] 【常】 이것이 붙은 시그니가 고른 능력을 얻는다. ②는 자기 효과도 막는 `EFFECT_NO_BOUNCE`로 근사
  for i,code in ipairs({EFFECT_NO_DOWN_BY_OPP,EFFECT_NO_BOUNCE}) do
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetDescription(aux.Ability(id,1))
    e2:SetCode(code)
    e2:SetRange(LOCATION_ACCE)
    e2:SetTargetRange(LOCATION_SZONE,0)
    e2:SetTarget(host)
    e2:SetCondition(function() return chosen[i-1] end)
    c:RegisterEffect(e2)
  end
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Stringid(id,2))
  g:SetCode(EVENT_ATTACK)
  g:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD)
  e3:SetDescription(aux.Ability(id,1))
  e3:SetCode(EFFECT_GRANT)
  e3:SetRange(LOCATION_ACCE)
  e3:SetTargetRange(LOCATION_SZONE,0)
  e3:SetTarget(host)
  e3:SetCondition(function() return chosen[2] end)
  e3:SetLabelObject(g)
  c:RegisterEffect(e3)
end
