-- WX06-031 ＴＲＩＣＫ　ＯＲ　ＴＲＥＡＴ
-- 以下の２つから１つを選ぶ。
-- ①カードを２枚引く。
-- ②対戦相手は手札を２枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==0 then Duel.Draw(tp,2) else aux.Discard(1-tp,2) end
  end)
  c:RegisterEffect(e1)
end
