-- WX19-064 ＰＵＬＬＩＮＧ
-- 以下の３つから１つを選ぶ。
-- ①【ウィルス】１つを取り除く。
-- ②【トラップ】１つを対象とし、それをトラッシュに置く。
-- ③シグニ１体を対象とし、それに付いているすべてのカードと、下に置かれているすべてのカードをトラッシュに置く。
-- 【トラップアイコン】：カードを１枚引く。その後、あなたの【トラップ】１つを対象とし、それを表向きにし《トラップアイコン》を発動させる。
-- ライフバースト：あなたのトラッシュから《トラップアイコン》を持つカード１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))[1])
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m==0 then
      local zones={}
      for p=0,1 do for _,z in ipairs(Duel.GetSigniZones(p)) do if Duel.HasVirus(z) then zones[#zones+1]=z end end end
      if #zones>0 then Duel.RemoveVirus(Duel.SelectZone(tp,zones)) end
    elseif m==1 then
      local tc=Duel.SelectTarget(tp,nil,tp,LOCATION_TRAP,LOCATION_TRAP,1,1,nil):GetFirst()
      if tc then Duel.SendToTrash(tc,REASON_EFFECT) end
    else
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then
    local g=tc:GetUnderGroup()
        local ch=tc:GetCharm()
        if ch then g:AddCard(ch) end
        for x in Duel.GetMatchingGroup(function(a) return a:GetAcceHost()==tc end,tp,LOCATION_ACCE,LOCATION_ACCE,nil):Iter() do g:AddCard(x) end
        if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
      end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_TRAP)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
    local tc=Duel.SelectTarget(tp,nil,tp,LOCATION_TRAP,0,1,1,nil):GetFirst()
    if tc then Duel.OpenTrap(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.HasTrapIcon,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e3)
end
