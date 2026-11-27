-- WX16-006 イノセント・ディフェンス
-- このアーツの使用コストに含まれる《無》コストは、あなたのセンタールリグが持つ色でしか支払えない。
-- 以下の４つから２つまで選ぶ。
-- ①対戦相手のセンタールリグ１体を対象とし、ターン終了時まで、それは「【常】：アタックできない。」を得る。
-- ②対戦相手のシグニ１体を対象とし、それをダウンし凍結する。
-- ③あなたのシグニ１体を対象とし、ターン終了時まで、それは「【常】：バニッシュされない。」を得る。
-- ④あなたのトラッシュからあなたのセンタールリグと共通する色を持つシグニを２枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 「《無》はセンタールリグが持つ色でしか支払えない」는 아직(근사)
  e1:SetDeclare(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m&1~=0 then
      local tc=Duel.SelectTarget(tp,nil,tp,0,LOCATION_LRIG,1,1,nil):GetFirst()
      if tc then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_ATTACK)
        e1:SetReset(RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
      end
    end
    if m&2~=0 then
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.Down(tc) Duel.Freeze(tc) end
    end
    if m&4~=0 then
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
      if tc then
    local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_BANISH)
        e1:SetReset(RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
      end
    end
    if m&8~=0 then
      local g=Duel.SelectTarget(tp,function(x) local lc=Duel.GetMatchingGroup(nil,x:GetOwner(),LOCATION_LRIG,0,nil):GetFirst() return x:IsSigni() and lc and x:GetColor()&lc:GetColor()~=0 end,tp,LOCATION_TRASH,0,0,2,nil)
      if g:GetCount()>0 then Duel.SendToHand(g) end
    end
  end)
  c:RegisterEffect(e1)
end
