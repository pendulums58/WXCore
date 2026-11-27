-- WX17-003 ネームレス・フィア―
-- ベット―《コインアイコン》《コインアイコン》
-- 以下から２つまで選ぶ。同じ選択肢を２回選んでもよい。あなたがベットしていた場合、代わりに４つまで選ぶ。同じ選択肢を２回以上選んでもよい。
-- ①対戦相手のシグニ１体を対象とし、それを手札に戻す。手札を１枚捨てる。
-- ②対戦相手のセンタールリグ１体を対象とし、ターン終了時まで、それは「【常】：アタックできない。」を得る。
-- ③あなたのデッキからレベルの異なる＜怪異＞のシグニ２枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(2)
  e1:SetOperation(function(e,tp)
    -- 같은 선택지를 여러 번 고를 수 있다. 하나씩 고른다(고르기를 멈추면 끝)
    local n=Duel.IsBet() and 4 or 2
    local picks={}
    for i=1,n do
      if i>1 and not Duel.SelectYesNo(tp) then break end
      picks[#picks+1]=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
    end
    table.sort(picks)
    for _,m in ipairs(picks) do
      if m==0 then
        local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
        if tc then Duel.SendToHand(tc) end
        aux.Discard(tp,1)
      elseif m==1 then
        local tc=Duel.SelectTarget(tp,nil,tp,0,LOCATION_LRIG,1,1,nil):GetFirst()
        if tc then
          local e1=Effect.CreateEffect(e:GetHandler())
          e1:SetType(EFFECT_TYPE_SINGLE)
          e1:SetCode(EFFECT_CANNOT_ATTACK)
          e1:SetReset(RESET_PHASE+PHASE_END)
          tc:RegisterEffect(e1)
        end
      else
        local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KAII)) end,tp,LOCATION_MDECK,0,nil)
        Duel.SetSelectCheck(function(sg) return sg:GetCount()<=2 and aux.DistinctLevels(sg) end)
        local pick=Duel.SelectCards(tp,g,0,2)
        if pick:GetCount()>0 then Duel.RevealCards(pick) Duel.SendToHand(pick) end
        aux.ShuffleDeck(tp)
      end
    end
  end)
  c:RegisterEffect(e1)
end
