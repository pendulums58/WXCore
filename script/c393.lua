-- PR-K072 パワー・オブ・ヒロインズ（WIXOSS熱闘列伝ちより☆ 付録）
-- ベット―《コインアイコン》
-- 以下の２つから１つを選ぶ。あなたがベットしていた場合、代わりに２つ選ぶ。
-- ①対戦相手のシグニ１体を対象とし、それをダウンする。カードを１枚引く。
-- ②あなたの手札から＜調理＞のシグニ１枚を場に出す。ターン終了時まで、そのシグニは能力を失う。その後、あなたのデッキから＜調理＞のシグニ１枚を探して対象のあなたの＜調理＞のシグニ１体の【アクセ】にし、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(1)
  e1:SetDeclare(function(e,tp)
    if Duel.IsBet() then e:SetLabel(3) else e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 and 1 or 2) end
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()&1~=0 then Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    local cook=function(x) return x:IsSigni() and x:IsClass(0,RACE_CHOURI) end
    if m&1~=0 then
      local tc=Duel.GetFirstTarget()
      if tc and tc:IsRelateToEffect(e) then Duel.Down(tc) end
      Duel.Draw(tp,1)
    end
    if m&2~=0 then
      local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(cook,tp,LOCATION_HAND,0,nil),1,1):GetFirst()
      if x then
        Duel.PutOnField(x,tp)
        if x:IsLocation(LOCATION_SZONE) then aux.GrantKeyword(e,x,EFFECT_LOSE_ABILITY) end  -- [まで] ターン終了時まで
      end
      local a=aux.Search(tp,cook,1):GetFirst()
      local host=Duel.SelectTarget(tp,function(c) return cook(c) and not c:IsAcce() end,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
      if a and host then Duel.Acce(a,host) end
      aux.ShuffleDeck(tp)
    end
  end)
  c:RegisterEffect(e1)
end
