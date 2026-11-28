-- SP26-001 トワリング（「Lostorage incited WIXOSS 3」 初回特典）
-- 以下の２つから１つを選ぶ。
-- ①あなたのデッキの上からカードを５枚見る。その中からカード１枚を【トラップ】としてあなたのシグニゾーンに設置してもよい。残りを好きな順番でデッキの一番上に置く。その後、あなたの【トラップ】１つを対象とし、それを表向きにし《トラップアイコン》を発動させる。
-- ②カードを２枚引き、手札１枚を【トラップ】としてあなたのシグニゾーンに設置する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  -- 【トラップ】이 있으면 하나를 반드시 발동시킨다(FAQ 2). 손패가 있으면 반드시 설치한다(FAQ 4)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==0 then
      local g=Duel.GetDecktopGroup(tp,5)
      if g:GetCount()>0 then
        Duel.ConfirmCards(tp,g)
        local x=Duel.SelectCards(tp,g,0,1):GetFirst()
        if x then Duel.SetTrap(x,tp) end
        local rest=g:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
        if rest:GetCount()>0 then aux.ToDeckTopInOrder(tp,rest) end
      end
      local t=Duel.SelectTarget(tp,nil,tp,LOCATION_TRAP,0,1,1,nil):GetFirst()
      if t then Duel.OpenTrap(t) end
    else
      Duel.Draw(tp,2)
      local h=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
      if h:GetCount()>0 then Duel.SetTrap(Duel.SelectCards(tp,h,1,1):GetFirst(),tp) end
    end
  end)
  c:RegisterEffect(e1)
end
