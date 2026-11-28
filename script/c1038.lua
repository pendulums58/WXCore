-- WXK07-106 ハット・トリック
-- ベット―《コインアイコン》《コインアイコン》
-- 以下の効果を１回行う。あなたがベットしていた場合、代わりに２回行う。
-- あなたのデッキの一番上のカードをトラッシュに置く。その後、この方法でトラッシュに置かれたカードが
-- レベルが奇数のシグニの場合、それをトラッシュから場に出す。
-- レベルが偶数のシグニの場合、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－12000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(2)
  e1:SetOperation(function(e,tp,eg)
    for i=1,(Duel.IsBet() and 2 or 1) do
      local g=Duel.GetDecktopGroup(tp,1)
      local x=g:GetFirst()
      if not x then break end
      Duel.SendToTrash(g,REASON_EFFECT)
      if x:IsSigni() and x:IsLocation(LOCATION_TRASH) then
        if x:GetLevel()%2==1 then Duel.PutOnField(x,tp)
        else
          local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
          if tc then aux.AddPower(e,tc,-12000) end
        end
      end
    end
  end)
  c:RegisterEffect(e1)
end
