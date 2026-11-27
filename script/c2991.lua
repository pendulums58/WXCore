-- WX18-038 特大幻蟲　ヨロズハタヒメ
-- 【常】：【チャーム】が付いている対戦相手のシグニは能力を失い、新たに得られない。
-- 【常】：【チャーム】が付いている対戦相手のシグニがバニッシュされる場合、エナゾーンに置かれる代わりにトラッシュに置かれる。
-- 【出】：対戦相手は自分のシグニ１体につき自分のデッキの上からカード１枚を、それらの【チャーム】にする。
-- ライフバースト：対戦相手の場にある【チャーム】の数に１を加えた枚数のカードを引く。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 둘. 「新たに得られない」는 능력 상실로 근사
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_LOSE_ABILITY)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(0,LOCATION_SZONE)
  e1:SetTarget(function(e,x) return x:GetCharm()~=nil end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_BANISH_TO_TRASH)
  e2:SetRange(LOCATION_SZONE)
  e2:SetTargetRange(0,LOCATION_SZONE)
  e2:SetTarget(function(e,x) return x:GetCharm()~=nil end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetOperation(function(e,tp)
    for x in Duel.GetMatchingGroup(function(c) return c:IsSigni() and not c:GetCharm() end,tp,0,LOCATION_SZONE,nil):Iter() do
      local top=Duel.GetDecktopGroup(1-tp,1):GetFirst()
      if top then Duel.Charm(top,x) end
    end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetOperation(function(e,tp)
    Duel.Draw(tp,Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetCharm()~=nil end,tp,0,LOCATION_SZONE,nil):GetCount()+1)
  end)
  c:RegisterEffect(e4)
end
