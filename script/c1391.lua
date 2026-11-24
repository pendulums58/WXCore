-- WD23-035-A 大罠　ワンクリック
-- 【起】《ダウン》：カードを１枚引くか、あなたの手札１枚を【トラップ】としてあなたのシグニゾーンに設置する。
-- （【トラップ】はシグニゾーン１つにつき１つまで裏向きで設置できる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    if g:GetCount()==0 or Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then
      Duel.Draw(tp,1)
    else
      Duel.SetTrap(Duel.SelectCards(tp,g,1,1):GetFirst(),tp)
    end
  end)
  c:RegisterEffect(e1)
end
