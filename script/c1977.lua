-- WX03-026 手弾　アヤボン
-- 【常】：あなたの場に《手剣　カクマル》があるかぎり、このシグニの基本パワーは8000になる。
-- 【常】：あなたのルリグトラッシュにカードが７枚以上あるかぎり、このシグニは【ダブルクラッシュ】を得る。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,8000,function(e) return Duel.GetMatchingGroup(function(x) return x:IsCardName(1974) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0 end)
  -- [の間] 【常】 그로우로 루리그 존에 있는 카드는 세지 않는다(FAQ 2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_DOUBLE_CRUSH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_LTRASH,0,nil):GetCount()>=7 end)
  c:RegisterEffect(e1)
end
