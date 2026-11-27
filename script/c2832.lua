-- WX16-005 ネバーエンド
-- ベット―《コインアイコン》《コインアイコン》
-- 以下の３つから１つを選ぶ。あなたがベットしていた場合、代わりに３つまで選ぶ。
-- ①レベルが場にある【ウィルス】の数以下の対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- ②あなたのトラッシュから、レベルが場にある【ウィルス】の数以下のシグニ１枚を対象とし、それを場に出す。そのシグニの【出】能力は発動しない。
-- ③対戦相手の場にある【ウィルス】３つを取り除く。そうした場合、あなたのデッキの一番上のカードをライフクロスに加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(2)
  e1:SetDeclare(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,Duel.IsBet() and 3 or 1,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m&1~=0 then
      local v=(function() local n=0 for p=0,1 do for _,z in ipairs(Duel.GetSigniZones(p)) do if Duel.HasVirus(z) then n=n+1 end end end return n end)()
      local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=v end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.Banish(tc) end
    end
    if m&2~=0 then
      local v=(function() local n=0 for p=0,1 do for _,z in ipairs(Duel.GetSigniZones(p)) do if Duel.HasVirus(z) then n=n+1 end end end return n end)()
      local x=Duel.SelectTarget(tp,function(c) return c:IsSigni() and c:GetLevel()<=v end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
      if x then Duel.PutOnField(x,tp,true) end
    end
    if m&4~=0 then
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
      local zones=0
      for _,z in ipairs(Duel.GetSigniZones(1-tp)) do if Duel.HasVirus(z) then zones=zones+1 end end
      if zones>=3 and remove_virus(3)==3 then
        local x=Duel.GetDecktopGroup(tp,1):GetFirst()
        if x then Duel.SendToLife(x) end
      end
    end
  end)
  c:RegisterEffect(e1)
end
