-- WX20-078 羅菌　エンザ
-- 【出】：以下の３つから１つを選ぶ。あなたのトラッシュにカード名に《インフル》を含むカードがある場合、代わりに２つまで選ぶ。
-- ①対戦相手の場にある【ウィルス】１つを取り除く。そうした場合、あなたのデッキの一番上のカードをエナゾーンに置くかカードを１枚引く。
-- ②対戦相手のシグニゾーン１つに【ウィルス】１つを置く。
-- ③対戦相手のシグニ１体を対象とし、それが感染状態の場合、ターン終了時まで、それのパワーを－5000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local k=(Duel.GetMatchingGroup(function(x) return aux.NameHas(x,"インフル") end,tp,LOCATION_TRASH,0,nil):GetCount()>0) and 2 or 1
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,k,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) do m=m|(1<<i) end
    if m&1~=0 then
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
      if remove_virus(1)>0 then if Duel.SelectYesNo(tp) then Duel.EnaCharge(tp,1) else Duel.Draw(tp,1) end end
    end
    if m&2~=0 then
    for _=1,1 do
      local zones={}
      for _,z in ipairs(Duel.GetSigniZones(1-tp)) do if not Duel.HasVirus(z) then zones[#zones+1]=z end end
      if #zones==0 then break end
      local z=Duel.SelectZone(tp,zones)
      if not z then break end
      Duel.PlaceVirus(z)
    end
    end
    if m&4~=0 then
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc and tc:IsInfected() then aux.AddPower(e,tc,-5000) end  -- [まで]
    end
  end)
  c:RegisterEffect(e1)
end
