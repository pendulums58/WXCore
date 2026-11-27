-- WX19-030 羅菌　ノロウス
-- 【常】：このシグニは対戦相手の場に【ウィルス】が３つ以上ある場合にしか新たに場に出すことができない。
-- 【出】対戦相手の場にある【ウィルス】１つを取り除く：あなたのデッキの一番上のカードをエナゾーンに置き、カードを１枚引く。その後、対戦相手のパワー8000以下のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②対戦相手のシグニゾーン１つに【ウィルス】１つを置く。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_CANNOT_PLAY)
  e1:SetCondition(function(e) return (function(p) local n=0 for _,z in ipairs(Duel.GetSigniZones(1-p)) do if Duel.HasVirus(z) then n=n+1 end end return n end)(e:GetHandlerPlayer())<3 end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local zones={}
    for _,z in ipairs(Duel.GetSigniZones(1-tp)) do if Duel.HasVirus(z) then zones[#zones+1]=z end end
    if chk==0 then return #zones>0 end
    Duel.RemoveVirus(Duel.SelectZone(tp,zones))
  end)
  e2:SetOperation(function(e,tp)
    Duel.EnaCharge(tp,1)
    Duel.Draw(tp,1)
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=8000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e3:SetOperation(function(e,tp)
    if e:GetLabel()==0 then Duel.Draw(tp,1) return end
    for _=1,1 do
      local zones={}
      for _,z in ipairs(Duel.GetSigniZones(1-tp)) do if not Duel.HasVirus(z) then zones[#zones+1]=z end end
      if #zones==0 then break end
      local z=Duel.SelectZone(tp,zones)
      if not z then break end
      Duel.PlaceVirus(z)
    end
  end)
  c:RegisterEffect(e3)
end
