-- WX09-017 羅輝石　マラカイト
-- 【常】：あなたのトラッシュに＜鉱石＞のシグニが５枚以上あるかぎり、このシグニの基本パワーは15000になり、このシグニは【ダブルクラッシュ】を得る。
-- 【常】：あなたのトラッシュに＜宝石＞のシグニが５枚以上あるかぎり、このシグニは対戦相手の、アーツ以外の効果を受けない。
-- ライフバースト：パワーが「あなたのトラッシュにある＜鉱石＞と＜宝石＞のシグニを合計した枚数×3000」以下の対戦相手のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local ore=function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KOUSEKI)) end,e:GetHandlerPlayer(),LOCATION_TRASH,0,nil):GetCount()>=5 end
  local gem=function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_HOUSEKI)) end,e:GetHandlerPlayer(),LOCATION_TRASH,0,nil):GetCount()>=5 end
  -- [の間] 【常】 셋
  aux.BasePower(c,15000,ore)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_DOUBLE_CRUSH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(ore)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_IMMUNE)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(gem)
  e2:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and not sc:IsType(TYPE_ARTS) end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local n=3000*Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KOUSEKI) or x:IsClass(0,RACE_HOUSEKI)) end,tp,LOCATION_TRASH,0,nil):GetCount()
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=n end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e3)
end
