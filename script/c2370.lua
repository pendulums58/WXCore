-- WX09-049 ＴＨＲＥＥ　ＳＷＩＴＣＨ
-- あなたの場に青のシグニが３体あり、それらが共通するクラスを持つ場合、カードを４枚引く。そうでない場合、カードを３枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,(function() local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsColor(COLOR_BLUE) end,tp,LOCATION_SZONE,0,nil) return g:GetCount()==3 and aux.ShareClass(g) end)() and 4 or 3)
  end)
  c:RegisterEffect(e1)
end
