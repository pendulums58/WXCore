-- WXK01-090 ＰＲＡＹＩＮＧ
-- 以下の２つから１つを選ぶ。
-- ①カードを２枚引き、手札を１枚捨てる。
-- ②対戦相手は手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e1:SetOperation(function(e,tp,eg)
    -- 버린 뒤 리프레시(FAQ 1)
    if e:GetLabel()==0 then Duel.Draw(tp,2) aux.Discard(tp,1) else aux.Discard(1-tp,1) end
  end)
  c:RegisterEffect(e1)
end
