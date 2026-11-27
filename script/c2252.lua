-- WX08-005 白羅星　ウラヌス
-- 【出現条件】 《メインフェイズアイコン》レゾナ１体をあなたの場からルリグトラッシュに置き、レゾナではないレベル３以上のシグニ１体をあなたの場からトラッシュに置く
-- 【常】：エナゾーン以外の領域にあるカードは白になる。
-- 【常】：このシグニは対戦相手の白のカードの効果を受けない。
local s,id=GetID()
function s.initial_effect(c)
  -- 레조나 1체 + 레조나가 아닌 레벨 3 이상 1체. 레조나 재료는 루리그 덱으로 돌아간다(근사: 원문은 루리그 트래시)
  aux.AddResonaProc(c,2,function(x) return x:IsSigni() and (x:IsType(TYPE_RESONA) or x:GetLevel()>=3) end,nil,nil,nil,function(g)
    return g:Filter(function(x) return x:IsType(TYPE_RESONA) end,nil):GetCount()==1
  end)
  -- [の間] 【常】 둘
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_CHANGE_COLOR)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SIGNI+LOCATION_CHEER+LOCATION_HAND+LOCATION_MDECK+LOCATION_LIFE+LOCATION_CHECK+LOCATION_TRASH+LOCATION_LRIG+LOCATION_LDECK+LOCATION_LTRASH,LOCATION_SIGNI+LOCATION_CHEER+LOCATION_HAND+LOCATION_MDECK+LOCATION_LIFE+LOCATION_CHECK+LOCATION_TRASH+LOCATION_LRIG+LOCATION_LDECK+LOCATION_LTRASH)
  e1:SetValue(COLOR_WHITE)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EFFECT_IMMUNE)
  e2:SetRange(LOCATION_SZONE)
  e2:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and sc:IsColor(COLOR_WHITE) end)
  c:RegisterEffect(e2)
end
