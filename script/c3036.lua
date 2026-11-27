-- WX19-004 アヴァロン・スロー
-- このアーツの使用コストに含まれる《無》コストは、白か黒でしか支払えない。
-- 【チェイン】《白》《白》《黒》《黒》
-- 以下の３つから２つまで選ぶ。
-- ①対戦相手のシグニ１体を対象とし、それをトラッシュに置く。
-- ②あなたのトラッシュからあなたのセンタールリグと共通する色を持つシグニ１枚を対象とし、それを場に出す。
-- ③あなたのルリグトラッシュからコストの合計が２以上のアーツ１枚を対象とし、それをルリグデッキに加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 「《無》は白か黒でしか払えない」는 아직(근사)
  e1:SetDeclare(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m&1~=0 then local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() if tc then Duel.SendToTrash(tc,REASON_EFFECT) end end
    if m&2~=0 then local x=Duel.SelectTarget(tp,function(x) local lc=Duel.GetMatchingGroup(nil,x:GetOwner(),LOCATION_LRIG,0,nil):GetFirst() return x:IsSigni() and lc and x:GetColor()&lc:GetColor()~=0 end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst() if x then Duel.PutOnField(x,tp) end end
    if m&4~=0 then local x=Duel.SelectTarget(tp,function(c) return c:IsType(TYPE_ARTS) and c:GetCostTotal()>=2 end,tp,LOCATION_LTRASH,0,1,1,nil):GetFirst() if x then Duel.SendToLrigDeck(Group.CreateGroup(x)) end end
    -- 【チェイン】
    do
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD)
      e1:SetCode(EFFECT_REDUCE_COST)
      e1:SetProperty(EFFECT_FLAG_NEXT_USE)
      e1:SetTargetRange(1,0)
      e1:SetTarget(function(e,x) return x:IsType(TYPE_ARTS) end)
      e1:SetEnaCost("{W}{W}")
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
      e1:SetEnaCost("{B}{B}")
      e1:SetValue(1)
      e1:SetReset(RESET_PHASE+PHASE_END)
      Duel.RegisterEffect(e1,tp)
    end
  end)
  c:RegisterEffect(e1)
end
