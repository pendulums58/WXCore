-- WX15-067 メルト・ファクト
-- このスペルを使用する際、対戦相手の場にある【ウィルス】を好きな数取り除いてもよい。この方法で【ウィルス】を１つ以上取り除いた場合、このスペルの使用コストは《黒×2》減る。
-- 以下の２つから１つを選ぶ。このスペルを使用する際、【ウィルス】を２つ以上取り除いていた場合、代わりに２つまで選ぶ。
-- ①あなたのトラッシュから黒のシグニ１枚を対象とし、それを手札に加える。
-- ②対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－7000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local function remove_virus(mx)
      local zones={}
      for _,z in ipairs(Duel.GetSigniZones(1-tp)) do if Duel.HasVirus(z) then zones[#zones+1]=z end end
      local n=#zones>0 and Duel.AnnounceNumber(tp,0,math.min(#zones,mx or #zones)) or 0
      local removed=0
      for _=1,n do
        local left={}
        for _,z in ipairs(zones) do if Duel.HasVirus(z) then left[#left+1]=z end end
        local z=Duel.SelectZone(tp,left)
        if z and Duel.RemoveVirus(z) then removed=removed+1 end
      end
      return removed
    end
    local n=Duel.SelectYesNo(tp) and remove_virus() or 0
    if n>=1 then Duel.SetUseCost(Duel.ReduceCost(Duel.GetUseCost(),"{B}",2)) end
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,n>=2 and 2 or 1,aux.Stringid(id,0),aux.Stringid(id,1))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local m=e:GetLabel()
    s.a=m&1~=0 and Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst() or nil
    s.b=m&2~=0 and Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() or nil
  end)
  e1:SetOperation(function(e,tp)
    -- 코스트를 줄이는 【ウィルス】 제거는 사용 선언 때. 최소 코스트 검사는 원래 코스트로 한다(근사)
    if s.a and s.a:IsRelateToEffect(e) then Duel.SendToHand(s.a) end
    if s.b and s.b:IsRelateToEffect(e) then aux.AddPower(e,s.b,-7000) end  -- [まで]
  end)
  c:RegisterEffect(e1)
end
