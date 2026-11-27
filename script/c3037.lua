-- WX19-005 謳金時代
-- ベット―《コインアイコン》《コインアイコン》
-- 以下の４つから２つまで選ぶ。あなたがベットしていた場合、代わりに３つまで選ぶ。
-- ①対戦相手のパワー12000以下のシグニ１体を対象とし、それをバニッシュする。
-- ②対戦相手は自分のエナゾーンからカード２枚を対象とし、対戦相手のエナゾーンにカードが４枚以上ある場合、それらをトラッシュに置く。
-- ③カードを３枚引く。その後、対戦相手はあなたの手札を１枚見ないで選び、あなたはそれを捨てる。
-- ④対戦相手のライフクロス１枚をクラッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(2)
  e1:SetDeclare(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,Duel.IsBet() and 3 or 2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m&1~=0 then local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=12000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() if tc then Duel.Banish(tc) end end
    if m&2~=0 then
      local g=Duel.SelectTarget(1-tp,nil,1-tp,LOCATION_ENA,0,2,2,nil)
      if Duel.GetMatchingGroup(nil,tp,0,LOCATION_ENA,nil):GetCount()>=4 and g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    end
    if m&4~=0 then
      Duel.Draw(tp,3)
      local h=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
      if h:GetCount()>0 then Duel.SendToTrash(Duel.SelectCards(1-tp,h,1,1),REASON_EFFECT+REASON_DISCARD) end
    end
    if m&8~=0 then Duel.Crush(1-tp,1) end
  end)
  c:RegisterEffect(e1)
end
