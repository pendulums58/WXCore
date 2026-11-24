-- WD21-010 炎得火失
-- 以下の２つから１つを選ぶ。
-- ①カードを４枚引く。その後、対戦相手はあなたの手札を２枚見ないで選び、あなたはそれらをゲームから除外する。
-- ②対戦相手のシグニ１体を対象とし、それをバニッシュする。対戦相手はカードを１枚引き、対戦相手はデッキの一番上のカードをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==1 then Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==0 then
      Duel.Draw(tp,4)
      -- 「見ないで選び」: 뒷면으로 고른다
      local g=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
      local n=math.min(2,g:GetCount())
      if n>0 then Duel.Exclude(Duel.SelectCards(1-tp,g,n,n)) end
      return
    end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
    Duel.Draw(1-tp,1)
    Duel.EnaCharge(1-tp,1)
  end)
  c:RegisterEffect(e1)
end
