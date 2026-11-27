-- WX16-023 ブラック・エイク
-- このアーツを使用する際、使用コストとして追加で対戦相手の場にある【ウィルス】を２つまで取り除いてもよい。
-- 以下の３つから、これの使用コストで取り除いた【ウィルス】の数に１を加えた数だけ選ぶ。
-- ①あなたのトラッシュから黒のシグニ１枚を対象とし、それを手札に加える。
-- ②対戦相手のトラッシュにあるカードを２枚まで対象とし、それらをゲームから除外する。
-- ③対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－7000する。
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
    local k=Duel.SelectYesNo(tp) and remove_virus(2) or 0
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,math.min(k+1,3),aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m&1~=0 then
      local x=Duel.SelectTarget(tp,function(c) return c:IsSigni() and c:IsColor(COLOR_BLACK) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
      if x then Duel.SendToHand(x) end
    end
    if m&2~=0 then
      local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_TRASH,0,2,nil)
      if g:GetCount()>0 then Duel.Exclude(g) end
    end
    if m&4~=0 then
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then aux.AddPower(e,tc,-7000) end  -- [まで]
    end
  end)
  c:RegisterEffect(e1)
end
