-- WX13-033 ＭＩＲＲＯＲ
-- カードを１枚引く。
-- あなたのルリグトラッシュからあなたのセンタールリグと完全に同一のルリグタイプを持つレベル０のルリグ１枚を対象とし、それをあなたのセンタールリグの下に置いてもよい。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if not lc then return end
    local t=lc:GetLrigTypes()
    local g=Duel.GetMatchingGroup(function(x)
      if not (x:IsType(TYPE_LRIG) and x:GetLevel()==0) then return false end
      local u=x:GetLrigTypes()
      if #u~=#t then return false end
      for i=1,#t do if u[i]~=t[i] then return false end end
      return true
    end,tp,LOCATION_LTRASH,0,nil)
    local x=Duel.SelectCards(tp,g,0,1)
    if x:GetCount()>0 then Duel.PutUnder(lc,x) end
  end)
  c:RegisterEffect(e1)
end
