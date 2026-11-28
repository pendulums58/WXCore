-- PR-463 カウンター・ヴァンプ（ウィクロスカード大全Ⅷ 付録）
-- ベット―《コインアイコン》
-- 以下の３つから１つを選ぶ。あなたがベットしていた場合、代わりに３つまで選ぶ。
-- ①対戦相手のシグニ１体を対象とし、このターンに対戦相手の効果によってあなたのシグニが場を離れていた場合、それをバニッシュする。
-- ②このターンに対戦相手の効果によってあなたのエナゾーンからカードがトラッシュに置かれていた場合、あなたのデッキの上からカードを３枚エナゾーンに置く。
-- ③このターンに対戦相手の効果によってあなたの手札からカードがトラッシュに移動していた場合、あなたの手札が６枚より少ない分だけカードを引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(1)
  e1:SetDeclare(function(e,tp)
    local d={aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2)}
    local ms=Duel.IsBet() and Duel.SelectModes(tp,1,3,table.unpack(d)) or {Duel.SelectOption(tp,table.unpack(d))}
    local bits=0
    for _,m in ipairs(ms) do bits=bits|(1<<m) end
    e:SetLabel(bits)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()&1~=0 then Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  -- 쓴 시점에 이 턴에 있었는지만 본다(FAQ 1·2). 룰 처리 바니시는 아니다(FAQ 3)
  e1:SetOperation(function(e,tp)
    local m,moved=e:GetLabel(),Duel.GetMovedByOpp(tp)
    if m&1~=0 and moved&1~=0 then
      local tc=Duel.GetFirstTarget()
      if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
    end
    if m&2~=0 and moved&2~=0 then
      local g=Duel.GetDecktopGroup(tp,3)
      if g:GetCount()>0 then Duel.SendToEna(g) end
    end
    if m&4~=0 and moved&4~=0 then
      local n=6-Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()
      if n>0 then Duel.Draw(tp,n) end
    end
  end)
  c:RegisterEffect(e1)
end
