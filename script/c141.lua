-- PR-242 一蓮托生（ウィクロスマガジンvol.3 付録）
-- 以下の２つから１つを選ぶ。
-- ①あなたのデッキからカードを２枚まで探してエナゾーンに置き、デッキをシャッフルする。
-- ②あなたのエナゾーンから対戦相手の選んだシグニ１枚を場に出す。（ルールや効果によって場に出すことのできないシグニが選ばれた場合、何も起きない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==0 then
      local g=aux.Search(tp,nil,2)
      if g:GetCount()>0 then Duel.SendToEna(g) end
      aux.ShuffleDeck(tp)
      return
    end
    -- 상대가 고르고 내가 존을 정한다(FAQ 2). 낼 수 없으면 아무 일도 없다(FAQ 1)
    local tc=Duel.SelectCards(1-tp,Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_ENA,0,nil),1,1):GetFirst()
    if tc then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e1)
end
