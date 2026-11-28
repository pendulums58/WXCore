-- WXEX1-78 羅菌　コレラ
-- 【出】：対戦相手のシグニゾーン１つに【ウィルス】１つを置く。
-- 【起】《ターン１回》対戦相手の場にある【ウィルス】２つを取り除く：あなたのトラッシュから《羅菌　コレラ》以外の＜微菌＞のシグニ１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local z=Duel.SelectZone(tp,Duel.GetSigniZones(1-tp))
    if z then Duel.PlaceVirus(z) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local function vzones()
      local t={}
      for _,z in ipairs(Duel.GetSigniZones(1-tp)) do
        if Duel.HasVirus(z) then t[#t+1]=z end
      end
      return t
    end
    if chk==0 then return #vzones()>=2 end
    for i=1,2 do
      local z=Duel.SelectZone(tp,vzones())
      if z then Duel.RemoveVirus(z) end
    end
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_BIKIN) and not x:IsCardName(id) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e2)
end
