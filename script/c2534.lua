-- WX12-005 クトゥル・コール
-- 以下の２つから１つを選ぶ。あなたのセンタールリグが＜タウィル＞か＜ウムル＞の場合、代わりに２つまで選ぶ。
-- ①対戦相手のセンタールリグかシグニ１体を対象とし、ターン終了時まで、それは「【常】：アタックできない。」を得る。
-- ②あなたのトラッシュから白か黒のシグニ１枚を対象とし、それを場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local m=0
    local n=((function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_TAWIL) end)() or (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_UMR) end)()) and 2 or 1
    for _,i in ipairs(Duel.SelectModes(tp,1,n,aux.Stringid(id,0),aux.Stringid(id,1))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local m=e:GetLabel()
    s.a=m&1~=0 and Duel.SelectTarget(tp,function(x) return x:IsSigni() or x:IsType(TYPE_LRIG) end,tp,0,LOCATION_SZONE+LOCATION_LRIG,1,1,nil):GetFirst() or nil
    s.b=m&2~=0 and Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsColor(COLOR_WHITE) or x:IsColor(COLOR_BLACK)) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst() or nil
  end)
  e1:SetOperation(function(e,tp)
    if s.a and s.a:IsRelateToEffect(e) then aux.GrantKeyword(e,s.a,EFFECT_CANNOT_ATTACK) end
    if s.b and s.b:IsRelateToEffect(e) then Duel.PutOnField(s.b,tp) end
  end)
  c:RegisterEffect(e1)
end
