-- SP27-010 火電一閃（セレクターズパック vol.18）
-- アンコール －あなたのセンタールリグの下からカード２枚をルリグトラッシュに置く
-- 以下の３つから１つを選ぶ。
-- ①レゾナではない対戦相手のレベル２以下のシグニ１体を対象とし、それをバニッシュする。
-- ②カードを１枚引く。このターンに対戦相手がスペルを使用していた場合、追加でカードを１枚引く。
-- ③対戦相手のパワー12000以下のシグニ１体を対象とし、あなたのライフクロスが０枚の場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2)))
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if lc and lc:GetUnderGroup():GetCount()>=2 and Duel.SelectYesNo(tp) then e:SetLabel(e:GetLabel()+10) end
  end)
  -- 앙코르 코스트는 엑시드 코스트가 아니다(FAQ 1)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if e:GetLabel()>=10 and lc then Duel.SendToLrigTrash(Duel.SelectCards(tp,lc:GetUnderGroup(),2,2),REASON_COST) end
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local m=e:GetLabel()%10
    if m==0 then Duel.SelectTarget(tp,function(x) return x:IsSigni() and not x:IsType(TYPE_RESONA) and x:GetLevel()<=2 end,tp,0,LOCATION_SZONE,1,1,nil)
    elseif m==2 then Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=12000 end,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()%10
    if m==1 then
      Duel.Draw(tp,1)
      if Duel.GetSpellsUsedCount(1-tp)>0 then Duel.Draw(tp,1) end
    else
      local tc=Duel.GetFirstTarget()
      if tc and tc:IsRelateToEffect(e) then
        if m==0 and tc:GetLevel()<=2 then Duel.Banish(tc) end
        if m==2 and tc:GetPower()<=12000 and Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()==0 then Duel.Banish(tc) end
      end
    end
    local me=e:GetHandler()
    if e:GetLabel()>=10 and me:IsLocation(LOCATION_CHECK) then Duel.SendToLrigDeck(me) end
  end)
  c:RegisterEffect(e1)
end
