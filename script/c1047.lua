-- WX17-021 大盤振舞
-- 好きな数のシグニを対象とし、ターン終了時まで、それらのパワーを合わせて＋20000する。この効果では1000単位でしか数字を割り振ることができない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local g=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,10,nil)
    local left=20
    local list={}
    for x in g:Iter() do list[#list+1]=x end
    for i,x in ipairs(list) do
      if left<=0 then break end
      local n=i==#list and left or Duel.AnnounceNumber(tp,0,left)
      if n>0 and x:IsRelateToEffect(e) then aux.AddPower(e,x,1000*n) end  -- [まで]
      left=left-n
    end
  end)
  c:RegisterEffect(e1)
end
