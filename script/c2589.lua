-- WX13-007 博愛の使者　サシェ・リュンヌ
-- 【常】：対戦相手は各ターンに一度しかアーツを使用できない。
-- 【起】《ターン１回》《メインフェイズアイコン》《アタックフェイズアイコン》エクシード１：あなたのシグニ１体を対象とし、それを手札に戻す。
-- 【起】《アタックフェイズアイコン》エクシード２：あなたのルリグデッキから好きな枚数の＜宇宙＞のレゾナを出現条件を無視して場に出す。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 상대는 각 턴에 아츠를 1번만
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_CANNOT_USE)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(0,1)
  e1:SetTarget(function(e,x) return x:IsType(TYPE_ARTS) and Duel.GetArtsUsedCount(1-e:GetHandlerPlayer())>=1 end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetExceedCost(1)
  e2:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetExceedCost(2)
  e3:SetTiming(TIMING_ATTACK)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_RESONA) and x:IsClass(0,RACE_UCHU) end,tp,LOCATION_LDECK,0,nil)
    for x in Duel.SelectCards(tp,g,0,g:GetCount()):Iter() do Duel.PutOnField(x,tp) end
  end)
  c:RegisterEffect(e3)
end
