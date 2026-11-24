-- WD16-013 コードアート　Ｏ・Ｓ・Ｓ
-- 【常】：あなたのセンタールリグが青で、このシグニが中央のシグニゾーンにあるかぎり、このシグニは「【自】：このシグニがアタックしたとき、対戦相手は手札を１枚捨てる。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Ability(id,0))
  g:SetCode(EVENT_ATTACK)
  g:SetOperation(function(e,tp) s.disc(1-tp,1) end)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SIGNI,0)
  e1:SetTarget(function(e,x)
    if x~=e:GetHandler() or not x:IsInZone("signi_center") then return false end
    local lc=Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_LRIG,0,nil):GetFirst()
    return lc and lc:IsColor(COLOR_BLUE)
  end)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
end
-- 「手札をＮ枚捨てる」: 모자라면 있는 만큼
function s.disc(p,n)
  n=math.min(n,Duel.GetMatchingGroup(nil,p,LOCATION_HAND,0,nil):GetCount())
  if n>0 then Duel.SendToTrash(Duel.SelectDiscard(p,n,n),REASON_EFFECT+REASON_DISCARD) end
end
