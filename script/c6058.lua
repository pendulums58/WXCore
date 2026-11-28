-- WXEX1-24 ナナシ　其ノ四ノ獄
-- 【起】《ターン１回》対戦相手の場にある【ウィルス】１つを取り除く：以下の３つから１つを選ぶ。
-- ①カードを１枚引き、【エナチャージ１】をする。
-- ②対戦相手のすべてのシグニゾーンに【ウィルス】を１つずつ置く。
-- ③このターン、対戦相手は【ウィルス】があるシグニゾーンにシグニを新たに配置することができない。
-- 【起】《メインフェイズアイコン》《アタックフェイズアイコン》《コインアイコン》《コインアイコン》：対戦相手の感染状態のシグニ１体を対象とし、それをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(1)
  e1:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2)))
  end)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local zs={}
    for _,z in ipairs(Duel.GetSigniZones(1-tp)) do
      if Duel.HasVirus(z) then zs[#zs+1]=z end
    end
    if chk==0 then return #zs>0 end
    local z=Duel.SelectZone(tp,zs)
    if z then Duel.RemoveVirus(z) end
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m==0 then
      Duel.Draw(tp,1)
      Duel.EnaCharge(tp,1)
    elseif m==1 then
      for _,z in ipairs(Duel.GetSigniZones(1-tp)) do Duel.PlaceVirus(z) end
    else
      -- [の間] このターン、【ウィルス】があるシグニゾーンに新たに配置できない
      for _,z in ipairs(Duel.GetSigniZones(1-tp)) do
        local ef=Effect.CreateEffect(e:GetHandler())
        ef:SetType(EFFECT_TYPE_FIELD)
        ef:SetCode(EFFECT_ZONE_LOCK)
        ef:SetTargetRange(0,1)
        ef:SetValue(z)
        ef:SetCondition(function() return Duel.HasVirus(z) end)
        ef:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(ef,tp)
      end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e2:SetCoinCost(2)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsInfected() end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
end
