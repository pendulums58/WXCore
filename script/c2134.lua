-- WX05-081 リバイブ・フレア
-- 以下の２つから２つまで選ぶ。
-- ①あなたのデッキの上からカードを３枚トラッシュに置く。その後、あなたのトラッシュからレベル２以下の黒のシグニ１枚を対象とし、それを場に出す。
-- ②あなたのトラッシュから黒のシグニ１枚を対象とし、あなたのセンタールリグがレベル４以上で黒の場合、それを場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m&1~=0 then
      local g=Duel.GetDecktopGroup(tp,3)
      if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
      local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) and x:IsLevelBetween(0,2) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
      if tc then Duel.PutOnField(tc,tp) end
    end
    if m&2~=0 then
      local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
      if tc and (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:GetLevel()>=4 and lc:IsColor(COLOR_BLACK) end)() then Duel.PutOnField(tc,tp) end
    end
  end)
  c:RegisterEffect(e1)
end
