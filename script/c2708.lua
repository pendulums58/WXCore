-- WX14-048 トキシック・スパイクス
-- 以下の２つから１つを選ぶ。
-- ①対象のあなたの＜毒牙＞のシグニ１体をバニッシュする。そうした場合、あなたのトラッシュから対象のレベル１の＜毒牙＞のシグニを２枚まで場に出す。
-- ②対象のあなたの＜毒牙＞のシグニ１体をバニッシュする。そうした場合、ターン終了時まで、対象の対戦相手のシグニ１体のパワーをあなたのトラッシュにあるそれぞれレベルの異なる＜毒牙＞のシグニ１枚につき－3000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    s.a=Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_DOKUGA)) end,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    if e:GetLabel()==0 then
      s.b=Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_DOKUGA)) end)(x) and x:GetLevel()==1 end,tp,LOCATION_TRASH,0,0,2,nil)
    else
      s.b=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    end
  end)
  e1:SetOperation(function(e,tp)
    if not (s.a and s.a:IsRelateToEffect(e)) or Duel.Banish(s.a)==0 then return end
    if e:GetLabel()==0 then
      for x in s.b:Iter() do if x:IsRelateToEffect(e) then Duel.PutOnField(x,tp) end end
      return
    end
    local seen,n={},0
    for x in Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_DOKUGA)) end,tp,LOCATION_TRASH,0,nil):Iter() do if not seen[x:GetLevel()] then seen[x:GetLevel()]=true n=n+1 end end
    if s.b and s.b:IsRelateToEffect(e) then aux.AddPower(e,s.b,-3000*n) end
  end)
  c:RegisterEffect(e1)
end
