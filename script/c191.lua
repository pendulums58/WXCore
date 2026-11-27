-- WX22-Re20 月欠けの戦場
-- 以下の３つから２つまで選ぶ。
-- ①対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーをあなたのセンタールリグのレベル１につき－2000する。
-- ②ターン終了時まで、対戦相手のすべてのシグニは「【常】：あなたが《無》を支払わないかぎりアタックできない。」を得る。
-- ③あなたのルリグトラッシュからレベル２以下のルリグを２枚まで対象とし、それらをあなたのセンタールリグの下に置く。
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
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m&1~=0 then
      local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc and lc then aux.AddPower(e,tc,-2000*lc:GetLevel()) end
    end
    if m&2~=0 then
      -- 「《無》を支払わないかぎりアタックできない」: 어택 금지로 근사
      for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do
    local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_ATTACK)
        e1:SetReset(RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
      end
    end
    if m&4~=0 then
      local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
      local g=Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_LRIG) and x:GetLevel()<=2 end,tp,LOCATION_LTRASH,0,0,2,nil)
      if lc and g:GetCount()>0 then Duel.PutUnder(lc,g) end
    end
  end)
  c:RegisterEffect(e1)
end
