-- WXEX1-31 先導の堕天使　シェムハザ
-- 【常】：あなたのエナゾーンとトラッシュに赤と青と緑のカードが１枚もないかぎり、あなたの＜天使＞のシグニは、対戦相手のルリグの効果を受けず、「【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、それを手札に戻す。」を得る。
-- 【出】《白》：あなたのデッキから＜天使＞のシグニ１枚を探して場に出し、デッキをシャッフルする。
-- ライフバースト：対象の対戦相手のセンタールリグかシグニ１体をダウンする。あなたのトラッシュから対象の＜天使＞のシグニ１枚を手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local function con(e)
    return Duel.GetMatchingGroup(function(x) return x:IsColor(COLOR_RED) or x:IsColor(COLOR_BLUE) or x:IsColor(COLOR_GREEN) end,e:GetHandlerPlayer(),LOCATION_ENA+LOCATION_TRASH,0,nil):GetCount()==0
  end
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetCondition(con)
  e1:SetTarget(function(e,x) return x:IsSigni() and x:IsClass(0,RACE_TENSHI) end)
  e1:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and sc and sc:IsType(TYPE_LRIG) end)
  c:RegisterEffect(e1)
  local atk=Effect.CreateEffect(c)
  atk:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  atk:SetCode(EVENT_ATTACK)
  atk:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  atk:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  local e1b=Effect.CreateEffect(c)
  e1b:SetType(EFFECT_TYPE_FIELD)
  e1b:SetCode(EFFECT_GRANT)
  e1b:SetRange(LOCATION_SZONE)
  e1b:SetTargetRange(LOCATION_SZONE,0)
  e1b:SetCondition(con)
  e1b:SetTarget(function(e,x) return x:IsSigni() and x:IsClass(0,RACE_TENSHI) end)
  e1b:SetLabelObject(atk)
  c:RegisterEffect(e1b)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{W}")
  e2:SetOperation(function(e,tp)
    local tc=aux.Search(tp,aux.ClassFilter(0,RACE_TENSHI),1):GetFirst()
    if tc then Duel.PutOnField(tc,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() or x:IsLocation(LOCATION_LRIG) end,tp,0,LOCATION_SZONE+LOCATION_LRIG,1,1,nil)
    Duel.SelectTarget(tp,aux.ClassFilter(0,RACE_TENSHI),tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e9:SetOperation(function(e,tp)
    for x in Duel.GetTargets():Filter(Card.IsRelateToEffect,nil,e):Iter() do
      if x:IsLocation(LOCATION_TRASH) then Duel.SendToHand(x) else Duel.Down(x) end
    end
  end)
  c:RegisterEffect(e9)
end
