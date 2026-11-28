-- SP27-016 決闘文具（セレクターズパック vol.20）
-- アンコール － あなたのセンタールリグの下からカード２枚をルリグトラッシュに置く
-- 以下の３つから１つを選ぶ。
-- ①あなたのデッキからあなたのセンタールリグと共通する色を持つカードを２枚まで探してエナゾーンに置き、デッキをシャッフルする。
-- ②このターン、対戦相手のセンタールリグかシグニがアタックしたとき、そのアタックがこのターン一度目の場合、そのアタックを無効にする。
-- ③ターン終了時まで、対戦相手のすべてのシグニは【シャドウ】【アサシン】【ランサー】【ダブルクラッシュ】を失い、それらを新たに得られない。
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
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()%10
    if m==0 then
      -- 무색 센터면 찾을 수 없다(FAQ 3)
      local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
      local col=lc and lc:GetColor() or 0
      local g=aux.Search(tp,function(x) return x:GetColor()&col~=0 end,2)
      if g:GetCount()>0 then Duel.SendToEna(g) end
      aux.ShuffleDeck(tp)
    elseif m==1 then
      -- [の間] 「このターン」 이 턴 첫 어택(시그니·루리그 통틀어, FAQ 5)이 상대의 것이면 무효. 이미 상대가 어택했으면 없다
      local done=Duel.GetMatchingGroup(function(x) return x:HasAttacked() end,tp,LOCATION_FIELD,LOCATION_FIELD,nil):GetCount()>0
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
      e1:SetCode(EVENT_ATTACK)
      e1:SetOperation(function(e2,tp2,eg)
        local x=eg:GetFirst()
        local first=not done
        done=true
        if first and x:GetControler()~=tp then Duel.NegateAttack() end
      end)
      e1:SetReset(RESET_PHASE+PHASE_END)
      Duel.RegisterEffect(e1,tp)
    else
      -- [まで] ターン終了時まで. 쓴 때 장에 있던 것만(FAQ 4)
      for x in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do
        for _,k in ipairs({EFFECT_SHADOW,EFFECT_ASSASSIN,EFFECT_LANCER,EFFECT_DOUBLE_CRUSH}) do
          local e1=Effect.CreateEffect(e:GetHandler())
          e1:SetType(EFFECT_TYPE_SINGLE)
          e1:SetCode(EFFECT_LOSE_KEYWORD)
          e1:SetValue(k)
          e1:SetReset(RESET_PHASE+PHASE_END)
          x:RegisterEffect(e1)
        end
      end
    end
    local me=e:GetHandler()
    if e:GetLabel()>=10 and me:IsLocation(LOCATION_CHECK) then Duel.SendToLrigDeck(me) end
  end)
  c:RegisterEffect(e1)
end
