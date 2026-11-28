-- SPK01-13 セレクト・ハッピー５（パーティーパックVol.5）
-- アンコール －キー１枚を場からルリグトラッシュに置く
-- 以下の５つから１つを選ぶ。
-- ①あなたのトラッシュからシグニ１枚を対象とし、それを手札に加える。
-- ②対戦相手のトラッシュにあるカードを２枚まで対象とし、それらをゲームから除外する。
-- ③このターン、あなたは対戦相手の効果によってダメージを受けない。
-- ④対戦相手のシグニ１体を対象とし、ターン終了時まで、それは「【常】：アタックできない。」を得る。
-- ⑤ターン終了時まで、対戦相手のすべてのシグニは効果によって得ている能力を失う。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 라벨: 모드 + (앙코르면 10). 앙코르는 내 키만(FAQ 1)
  e1:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3),aux.Stringid(id,4)))
    if Duel.GetMatchingGroup(nil,tp,LOCATION_KEY,0,nil):GetCount()>0 and Duel.SelectYesNo(tp) then e:SetLabel(e:GetLabel()+10) end
  end)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()>=10 then Duel.SendToLrigTrash(Duel.SelectCards(tp,Duel.GetMatchingGroup(nil,tp,LOCATION_KEY,0,nil),1,1),REASON_COST) end
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local m=e:GetLabel()%10
    if m==0 then Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil)
    elseif m==1 then Duel.SelectTarget(tp,nil,tp,0,LOCATION_TRASH,0,2,nil)
    elseif m==3 then Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()%10
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if m==0 then
      if g:GetCount()>0 then Duel.SendToHand(g) end
    elseif m==1 then
      if g:GetCount()>0 then Duel.Exclude(g) end
    elseif m==2 then
      -- [の間] 「このターン」 효과 데미지만. 어택·【ランサー】는 막지 않는다(FAQ 3)
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD)
      e1:SetCode(EFFECT_NO_DAMAGE)
      e1:SetTargetRange(1,0)
      e1:SetValue(1)
      e1:SetReset(RESET_PHASE+PHASE_END)
      Duel.RegisterEffect(e1,tp)
    elseif m==3 then
      local tc=g:GetFirst()
      if tc then
        -- [まで] ターン終了時まで
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_ATTACK)
        e1:SetReset(RESET_PHASE+PHASE_END)
        tc:GrantEffect(e1)
      end
    else
      -- 쓴 때 효과로 얻어 있던 능력만(FAQ 5). 【常】이 주는 것은 남는다(근사)
      for x in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do Duel.LoseGranted(x) end
    end
    local me=e:GetHandler()
    if e:GetLabel()>=10 and me:IsLocation(LOCATION_CHECK) then Duel.SendToLrigDeck(me) end
  end)
  c:RegisterEffect(e1)
end
