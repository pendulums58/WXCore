-- WX16-048 バッド・アドバンテージ
-- このスペルを使用する際、使用コストとして追加で対戦相手の場にある【ウィルス】を好きな数取り除いてもよい。
-- 以下の４つから、追加で取り除いた【ウィルス】の数に１を加えた数だけ選ぶ。
-- ①対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－7000する。
-- ②ターン終了時まで、対戦相手のすべてのシグニのパワーを－2000する。
-- ③あなたのトラッシュから黒のシグニ１枚を対象とし、それを手札に加える。
-- ④各プレイヤーは自分のデッキの上からカードを５枚トラッシュに置く。
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
    local k=Duel.SelectYesNo(tp) and remove_virus(nil) or 0
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,math.min(k+1,4),aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m&1~=0 then
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then aux.AddPower(e,tc,-7000) end  -- [まで]
    end
    if m&2~=0 then for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do aux.AddPower(e,tc,-2000) end end
    if m&4~=0 then
      local x=Duel.SelectTarget(tp,function(c) return c:IsSigni() and c:IsColor(COLOR_BLACK) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
      if x then Duel.SendToHand(x) end
    end
    if m&8~=0 then for p=0,1 do local g=Duel.GetDecktopGroup(p,5) if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end end end
  end)
  c:RegisterEffect(e1)
end
