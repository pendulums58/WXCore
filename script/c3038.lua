-- WX19-006 ダウト・クリューソス
-- ベット―《コインアイコン》《コインアイコン》
-- 以下の３つから１つを選ぶ。あなたがベットしていた場合、代わりに２つまで選ぶ。
-- ①対戦相手のレベル４以上のシグニ１体を対象とし、それをトラッシュに置く。
-- ②あなたのトラッシュから対戦相手の選んだカード１枚をライフクロスに加える。
-- ③対戦相手のトラッシュにあるすべてのスペルをゲームから除外する。この方法でスペルを２枚以上ゲームから除外した場合、カードを２枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(2)
  e1:SetDeclare(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,Duel.IsBet() and 2 or 1,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m&1~=0 then local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()>=4 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() if tc then Duel.SendToTrash(tc,REASON_EFFECT) end end
    if m&2~=0 then
      local g=Duel.GetMatchingGroup(nil,tp,LOCATION_TRASH,0,nil)
      local x=g:GetCount()>0 and Duel.SelectCards(1-tp,g,1,1):GetFirst() or nil
      if x then Duel.SendToLife(x) end
    end
    if m&4~=0 then
      local g=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_SPELL) end,tp,0,LOCATION_TRASH,nil)
      if g:GetCount()>0 and Duel.Exclude(g)>=2 then Duel.Draw(tp,2) end
    end
  end)
  c:RegisterEffect(e1)
end
