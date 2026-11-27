-- WX14-CB04 幻獣　キタキツネ
-- 【自】：このシグニがアタックしたとき、ターン終了時まで、あなたのすべての＜空獣＞と＜地獣＞のシグニのパワーを＋3000する。
-- 【自】：このシグニがアタックしたとき、あなたの場にパワー10000以上のシグニがある場合、カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KUJU) or x:IsClass(0,RACE_CHIJU)) end,tp,LOCATION_SZONE,0,nil):Iter() do aux.AddPower(e,tc,3000) end  -- [まで]
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetPower()>=10000 end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e2)
end
