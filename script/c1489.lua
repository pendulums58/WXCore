-- WX22-016 グレイブ・ディガー
-- ベット―好きな枚数の《コインアイコン》
-- あなたがベットする《コインアイコン》１枚につき以下の２つから１つを選ぶ。同じ選択肢を２回以上選んでもよい。
-- ①このアーツの使用コストは《黒×3》減る。
-- ②このアーツの効果を一度繰り返す。
-- 対象の対戦相手のシグニ１体をバニッシュし、あなたのトラッシュから対象の＜遊具＞のシグニ１枚を手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 「ベット―好きな枚数」: 코인 1개마다 코스트 감소 또는 반복을 고른다(사용 선언 때 고르는 것으로 근사)
  e1:SetDeclare(function(e,tp)
    local n=Duel.GetCoin(tp)>0 and Duel.AnnounceNumber(tp,0,Duel.GetCoin(tp)) or 0
    local rep=0
    for _=1,n do
      if Duel.SelectYesNo(tp) then Duel.SetUseCost(Duel.ReduceCost(Duel.GetUseCost(),"{B}",3)) else rep=rep+1 end
    end
    if n>0 then Duel.AddCoin(tp,-n) end
    e:SetLabel(rep)
  end)
  e1:SetOperation(function(e,tp)
    for _=0,e:GetLabel() do
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.Banish(tc) end
      local x=Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
      if x then Duel.SendToHand(x) end
    end
  end)
  c:RegisterEffect(e1)
end
