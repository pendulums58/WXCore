-- WX10-022 ウトゥルス・チェイン
-- 【チェイン】《黒》《白》（このターン、あなたが次にアーツを使用する場合、それの使用コストは《黒×1》《白×1》減る）
-- 以下の３つから１つを選ぶ。
-- ①対戦相手のレベル３以下のシグニ１体を対象とし、それを手札に戻す。
-- ②対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－12000する。
-- ③あなたのトラッシュから白か黒のシグニを合計２枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local m=e:GetLabel()
    if m&1~=0 then s.t0=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() end
    if m&2~=0 then s.t1=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() end
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if s.t0 and s.t0:IsRelateToEffect(e) then Duel.SendToHand(s.t0) end
    if s.t1 and s.t1:IsRelateToEffect(e) then aux.AddPower(e,s.t1,-12000) end
    if m&4~=0 then
      local g=Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsColor(COLOR_WHITE) or x:IsColor(COLOR_BLACK)) end,tp,LOCATION_TRASH,0,0,2,nil)
      if g:GetCount()>0 then Duel.SendToHand(g) end
    end
    -- 【チェイン】
    do
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD)
      e1:SetCode(EFFECT_REDUCE_COST)
      e1:SetProperty(EFFECT_FLAG_NEXT_USE)
      e1:SetTargetRange(1,0)
      e1:SetTarget(function(e,x) return x:IsType(TYPE_ARTS) end)
      e1:SetEnaCost("{B}")
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
      e1:SetEnaCost("{W}")
      e1:SetValue(1)
      e1:SetReset(RESET_PHASE+PHASE_END)
      Duel.RegisterEffect(e1,tp)
    end
  end)
  c:RegisterEffect(e1)
end
