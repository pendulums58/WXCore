-- WXEX1-37 コードアクセル　アパッチ
-- 【常】：あなたのドライブ状態のシグニは対戦相手の、キーとアーツの効果を受けない。
-- 【自】《ターン１回》：あなたのシグニ１体がドライブ状態になったとき、あなたの＜乗機＞のシグニ１体を対象とし、ターン終了時まで、それは【アサシン】を得る。
-- ライフバースト：あなたのトラッシュから＜乗機＞のシグニ１枚を対象とし、それを手札に加えるか場に出す。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x:IsSigni() and x:IsDrive() end)
  e1:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and sc and (sc:IsType(TYPE_KEY) or sc:IsType(TYPE_ARTS)) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_DRIVE)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCondition(function(e,tp,eg)
    return eg:Filter(function(x) return x:IsSigni() and x:GetControler()==tp end,nil):GetCount()>0
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,aux.ClassFilter(0,RACE_JOUKI),tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.GrantKeyword(e,tc,EFFECT_ASSASSIN) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,aux.ClassFilter(0,RACE_JOUKI),tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e9:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then Duel.SendToHand(tc) else Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e9)
end
