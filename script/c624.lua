-- WX14-005 水天一碧
-- 【チェイン】《緑》《青》
-- 以下の４つから２つまで選ぶ。
-- ①対戦相手のシグニを２体まで対象とし、それらをダウンする。
-- ②あなたのエナゾーンからカードを２枚まで対象とし、それらを手札に加える。
-- ③あなたのデッキの上からカードを２枚エナゾーンに置く。
-- ④カードを２枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local m=e:GetLabel()
    s.t0=m&1~=0 and Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil) or nil
    s.t1=m&2~=0 and Duel.SelectTarget(tp,nil,tp,LOCATION_ENA,0,0,2,nil) or nil
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m&1~=0 and s.t0 then for x in s.t0:Iter() do if x:IsRelateToEffect(e) then Duel.Down(x) end end end
    if m&2~=0 and s.t1 then local h=s.t1:Filter(function(x) return x:IsRelateToEffect(e) end,nil) if h:GetCount()>0 then Duel.SendToHand(h) end end
    if m&4~=0 then Duel.EnaCharge(tp,2) end
    if m&8~=0 then Duel.Draw(tp,2) end
    -- 【チェイン】
    do
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD)
      e1:SetCode(EFFECT_REDUCE_COST)
      e1:SetProperty(EFFECT_FLAG_NEXT_USE)
      e1:SetTargetRange(1,0)
      e1:SetTarget(function(e,x) return x:IsType(TYPE_ARTS) end)
      e1:SetEnaCost("{G}")
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
      e1:SetEnaCost("{U}")
      e1:SetValue(1)
      e1:SetReset(RESET_PHASE+PHASE_END)
      Duel.RegisterEffect(e1,tp)
    end
  end)
  c:RegisterEffect(e1)
end
