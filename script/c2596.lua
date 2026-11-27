-- WX13-015 アンダー・ワン
-- アンコール －《青》《無》（アンコールコストを追加で支払って使用してもよい。そうした場合、これは追加で「このカードをルリグデッキに戻す。」を得る）
-- コストの合計が１以下のスペル１つを対象とし、それの効果を打ち消す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetEncoreCost("{U}{C}")
  e1:SetOperation(function(e,tp)
    local sp=Duel.GetCutinSpell()
    if sp and sp:GetCostTotal()<=1 then Duel.NegateSpell() end
  end)
  c:RegisterEffect(e1)
end
