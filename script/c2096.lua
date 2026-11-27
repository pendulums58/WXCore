-- WX05-034 至宝の欠片
-- このスペルの使用コストはあなたのライフクロス１枚につき《無×1》増える。
-- ターン終了時まで、あなたのすべての＜鉱石＞と＜宝石＞のシグニは【ダブルクラッシュ】を得る。
-- ライフバースト：このターンと次のターンの間、あなたの中央のシグニゾーンにあるシグニは【ダブルクラッシュ】を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) return base..string.rep("{C}",Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()) end)
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KOUSEKI) or x:IsClass(0,RACE_HOUSEKI)) end,tp,LOCATION_SZONE,0,nil):Iter() do aux.GrantKeyword(e,tc,EFFECT_DOUBLE_CRUSH) end  -- [まで]
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    -- [の間] 이 턴과 다음 턴, 중앙 시그니 존의 시그니(FAQ 1)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_DOUBLE_CRUSH)
    e1:SetTargetRange(LOCATION_SIGNI,0)
    e1:SetTarget(function(e,x) return x:IsInZone("signi_center") end)
    e1:SetReset(RESET_PHASE+PHASE_END,2)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e2)
end
