-- WXK07-003 カオス・アウトブレイク
-- あなたのセンタールリグが＜ミュウ＞の場合、このアーツの使用コストは《黒×2》減る。
-- 対象の対戦相手のレベル３以下のシグニ１体をバニッシュする。ターン終了時まで、対象の対戦相手のシグニ１体の基本パワーを０にする。対戦相手のシグニゾーン１つにある、シグニではないすべてのカードをトラッシュに置く。（裏向きのカードとシグニに付いているカードと下にあるカードをトラッシュに置く）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  -- 「シグニではないすべてのカード」는 【チャーム】·【トラップ】·下にあるカード
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    local a=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    local b=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    local zs={}
    for _,z in ipairs(Duel.GetSigniZones(1-tp)) do zs[#zs+1]=z end
    local z=Duel.SelectZone(tp,zs)
    if a then Duel.Banish(a) end
    if b and b:IsLocation(LOCATION_SZONE) then
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_SET_BASE_POWER)
      e1:SetValue(0)
      e1:SetReset(RESET_PHASE+PHASE_END)
      b:GrantEffect(e1)
    end
    if not z then return end
    local g=Group.CreateGroup()
    local tr=Duel.GetTrap(z)
    if tr then g:AddCard(tr) end
    for x in Duel.GetMatchingGroup(function(x) return x:GetZone()==z end,1-tp,LOCATION_SZONE,0,nil):Iter() do
      if x:GetCharm() then g:AddCard(x:GetCharm()) end
      for y in x:GetUnderGroup():Iter() do g:AddCard(y) end
    end
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  aux.SetCostBy(e1,function(e,tp,base) if (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_MYU) end)() then return Duel.ReduceCost(base,"{B}{B}",1) end return base end)
end
