-- WD11-018 ゲット・インセクト
-- あなたのトラッシュから黒のシグニ１枚を対象とし、それを手札に加える。その後、あなたの場にレゾナがある場合、追加であなたのトラッシュから黒のシグニ１枚を対象とし、それを手札に加える。
-- ライフバースト：あなたのトラッシュから黒のシグニ１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(s.tg)
  -- 「その後」의 대상은 처리 중에 고른다
  e1:SetOperation(function(e,tp)
    s.op(e,tp)
    if Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_RESONA) end,tp,LOCATION_SZONE,0,nil):GetCount()==0 then return end
    local tc=Duel.SelectTarget(tp,s.filter,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if tc then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(s.tg)
  e2:SetOperation(s.op)
  c:RegisterEffect(e2)
end
function s.filter(c) return c:IsSigni() and c:IsColor(COLOR_BLACK) end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SelectTarget(tp,s.filter,tp,LOCATION_TRASH,0,1,1,nil)
end
function s.op(e,tp)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
end
