-- WXK04-014 血晶操作
-- ベット―《コインアイコン》
-- 以下の３つから１つを選ぶ。あなたがベットしていた場合、代わりに２つまで選ぶ。
-- ①カードを４枚引く。あなたは手札から＜紅蓮＞のシグニを１枚捨てないかぎり、カードを２枚捨てる。
-- ②このターン、あなたは対戦相手のルリグによってダメージを受けない。
-- ③あなたの＜紅蓮＞のシグニ１体を対象とし、それを血晶武装［トラッシュ］する。
-- （指定された領域［トラッシュ］からシグニの下にそれと同名のカード１枚を置くことでそのシグニは血晶武装状態になる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(1)
  e1:SetDeclare(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,Duel.IsBet() and 2 or 1,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()&4~=0 then Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_GUREN) end,tp,LOCATION_SZONE,0,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp,eg)
    local m=e:GetLabel()
    if m&1~=0 then
      Duel.Draw(tp,4)
      local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_GUREN) end,tp,LOCATION_HAND,0,nil)
      if not (g:GetCount()>0 and Duel.SelectYesNo(tp) and Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT+REASON_DISCARD)>0) then aux.Discard(tp,2) end
    end
    if m&2~=0 then
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_NO_LRIG_DAMAGE)
    e1:SetTargetRange(1,0)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    end
    if m&4~=0 then
      local tc=Duel.GetFirstTarget()
      if tc and tc:IsRelateToEffect(e) then aux.BloodArm(tp,tc,LOCATION_TRASH) end
    end
  end)
  c:RegisterEffect(e1)
end
