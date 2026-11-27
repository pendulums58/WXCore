-- WX15-113 羅菌　メンタグロ
-- 【出】手札から＜微菌＞のシグニを１枚捨てる：カードを１枚引き、対戦相手のシグニゾーン１つに【ウィルス】１つを置く。
-- （【ウィルス】はシグニゾーン１つにつき１つまでしか置けない）
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(aux.DiscardCost(1,function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKIN)) end))
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
    for _=1,1 do
      local zones={}
      for _,z in ipairs(Duel.GetSigniZones(1-tp)) do if not Duel.HasVirus(z) then zones[#zones+1]=z end end
      if #zones==0 then break end
      local z=Duel.SelectZone(tp,zones)
      if not z then break end
      Duel.PlaceVirus(z)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
end
