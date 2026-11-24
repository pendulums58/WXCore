-- WD16-010 ピーピング・チャージ
-- 対戦相手の手札を見る。
-- このターン、あなたが次に《ピーピング・アナライズ》を使用する場合、それの使用コストはあなたのセンタールリグのレベル１につき《青×1》減る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    Duel.ConfirmCards(tp,Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil))
    -- [の間] 「このターン」. 두 번 쓰면 겹친다(FAQ 1). 1118 = 《ピーピング・アナライズ》
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_REDUCE_COST)
    e1:SetProperty(EFFECT_FLAG_NEXT_USE)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(e,c) return c:GetCode()==1118 end)
    e1:SetEnaCost("{U}")
    e1:SetValue(function(e)
      local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
      return lc and lc:GetLevel() or 0
    end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
