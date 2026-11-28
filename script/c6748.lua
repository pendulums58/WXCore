-- WXK07-050 観取
-- あなたのトラッシュから対象の＜微菌＞のシグニ１枚を対象のあなたのシグニ１体の【チャーム】にする。ターン終了時まで、【チャーム】が付いているあなたのすべてのシグニのパワーを＋3000する。ターン終了時まで、あなたのパワー10000以上のすべてのシグニは【ランサー】を得、15000以上のすべてのシグニは【Ｓランサー】を得る。
-- （【Ｓランサー】を持つシグニがバトルでシグニをバニッシュしたとき、対戦相手のライフクロスがある場合はそれを１枚クラッシュする。無い場合は対戦相手にダメージを与える）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    local ch=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_BIKIN) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    local host=Duel.SelectTarget(tp,function(x) return x:IsSigni() and not x:GetCharm() end,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    if ch and host then Duel.Charm(ch,host) end
    for x in Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetCharm()~=nil end,tp,LOCATION_SZONE,0,nil):Iter() do aux.AddPower(e,x,3000) end
    for x in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do
      if x:GetPower()>=15000 then aux.GrantKeyword(e,x,EFFECT_S_LANCER) elseif x:GetPower()>=10000 then aux.GrantKeyword(e,x,EFFECT_LANCER) end
    end
  end)
  c:RegisterEffect(e1)
end
