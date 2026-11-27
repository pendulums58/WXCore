-- WX18-016 アナザー・ドロー
-- アンコール －《コインアイコン》《コインアイコン》
-- （アンコールコストを追加で支払って使用してもよい。そうした場合、これは追加で「このカードをルリグデッキに戻す。」を得る）
-- カードを３枚引き、手札を２枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetEncore(2)
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,3)
    aux.Discard(tp,2)
  end)
  c:RegisterEffect(e1)
end
