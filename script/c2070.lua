-- WX04-103 エビルズ・ソウル
-- 対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーをあなたの場にある＜悪魔＞のシグニのレベルを合計した数だけ－1000する。その後、あなたの＜悪魔＞のシグニ１体を対象とし、このスペルをそれの【チャーム】にしてもよい。
-- （【チャーム】は裏向きでシグニに付き、１体に１枚までしか付けられない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  -- 처리할 때의 레벨 합계(FAQ 1)
  e1:SetOperation(function(e,tp)
    local tc,n=Duel.GetFirstTarget(),0
    for x in Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_AKUMA)) end,tp,LOCATION_SZONE,0,nil):Iter() do n=n+x:GetLevel() end
    if tc and tc:IsRelateToEffect(e) and n>0 then aux.AddPower(e,tc,-1000*n) end  -- [まで] ターン終了時まで
    local host=Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_AKUMA)) end)(x) and not x:GetCharm() end,tp,LOCATION_SZONE,0,0,1,nil):GetFirst()
    if host then Duel.Charm(e:GetHandler(),host) end
  end)
  c:RegisterEffect(e1)
end
