-- WD13-013 先駆の大天使　アークゲイン
-- 【常】：あなたの＜天使＞のシグニは対戦相手のルリグ以外からの効果を受けない。
-- 【出】《白》《白》：あなたのデッキから＜天使＞のシグニ１枚を探して場に出し、デッキをシャッフルする。
-- ライフバースト：あなたのデッキから＜天使＞のシグニ１枚を探して公開し手札に加える。その後、デッキをシャッフルし、対戦相手のセンタールリグかシグニ１体を対象とし、それをダウンする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 자기 효과는 받는다(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x:IsSigni() and x:IsClass(0,RACE_TENSHI) end)
  e1:SetValue(function(e,sc,sp)
    return sp~=e:GetHandlerPlayer() and not (sc:IsType(TYPE_LRIG) or sc:IsType(TYPE_ASSIST_LRIG))
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{W}{W}")
  e2:SetOperation(function(e,tp)
    local tc=aux.Search(tp,s.tenshi,1):GetFirst()
    if tc then Duel.PutOnField(tc,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    aux.SearchToHand(tp,s.tenshi,1)
    local tc=Duel.SelectTarget(tp,nil,tp,0,LOCATION_LRIG+LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Down(tc) end
  end)
  c:RegisterEffect(e3)
end
function s.tenshi(c) return c:IsSigni() and c:IsClass(0,RACE_TENSHI) end
