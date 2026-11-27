-- WX16-Re06 小剣　ミカムネ
-- 【常】：あなたの場に白ではないシグニがある場合、このシグニの基本パワーは5000になる。
-- 【常】：このシグニがエナゾーンにあるかぎり、あなたは自分のセンタールリグが持つ色のエナ１つを支払う際に、代わりにあなたのエナゾーンからこのシグニをトラッシュに置いてもよい。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,5000,function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and not x:IsColor(COLOR_WHITE) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0 end)
  -- [の間] 【常】 에나 존에서 센터 루리그 색 에나 1개 대신
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_MULTI_ENA)
  e1:SetRange(LOCATION_ENA)
  c:RegisterEffect(e1)
  -- 「センタールリグが持つ色」로 한정하는 것은 아직(근사: 【マルチエナ】)
end
