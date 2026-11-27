-- WX10-004 チェイン・Ｗキャノン
-- 【チェイン】《白》《赤》（このターン、あなたが次にアーツを使用する場合、それの使用コストは《白×1》《赤×1》減る）
-- 以下の３つから２つまで選ぶ。
-- ①対戦相手のシグニ１体を対象とし、ターン終了時まで、それは「【常】：アタックできない。」を得る。
-- ②対戦相手のパワー7000以下のシグニ１体を対象とし、それをバニッシュする。
-- ③あなたのシグニ１体を対象とし、ターン終了時まで、それは【ダブルクラッシュ】を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local m=e:GetLabel()
    if m&1~=0 then s.t0=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() end
    if m&2~=0 then s.t1=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=7000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() end
    if m&4~=0 then s.t2=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil):GetFirst() end
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    -- [まで] ターン終了時まで
    if s.t0 and s.t0:IsRelateToEffect(e) then aux.GrantKeyword(e,s.t0,EFFECT_CANNOT_ATTACK) end
    if s.t1 and s.t1:IsRelateToEffect(e) then Duel.Banish(s.t1) end
    if s.t2 and s.t2:IsRelateToEffect(e) then aux.GrantKeyword(e,s.t2,EFFECT_DOUBLE_CRUSH) end
    -- 【チェイン】
    do
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD)
      e1:SetCode(EFFECT_REDUCE_COST)
      e1:SetProperty(EFFECT_FLAG_NEXT_USE)
      e1:SetTargetRange(1,0)
      e1:SetTarget(function(e,x) return x:IsType(TYPE_ARTS) end)
      e1:SetEnaCost("{W}")
      e1:SetValue(1)
      e1:SetReset(RESET_PHASE+PHASE_END)
      Duel.RegisterEffect(e1,tp)
    end
    -- 【チェイン】
    do
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD)
      e1:SetCode(EFFECT_REDUCE_COST)
      e1:SetProperty(EFFECT_FLAG_NEXT_USE)
      e1:SetTargetRange(1,0)
      e1:SetTarget(function(e,x) return x:IsType(TYPE_ARTS) end)
      e1:SetEnaCost("{R}")
      e1:SetValue(1)
      e1:SetReset(RESET_PHASE+PHASE_END)
      Duel.RegisterEffect(e1,tp)
    end
  end)
  c:RegisterEffect(e1)
end
