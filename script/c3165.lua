-- WX20-079 コードアンチ　ソトホート
-- 【起】《ターン１回》《アタックフェイズアイコン》《黒×0》：対戦相手のシグニ１体を対象とし、あなたのトラッシュからそれぞれレベルの異なる黒のシグニ４枚をシャッフルしてデッキの一番下に置く。そうした場合、ターン終了時まで、それのパワーを－7000する。この能力はあなたのトラッシュにカード名に《ヨグソトス》を含むカードがある場合にしか使用できない。
-- 【起】《アタックフェイズアイコン》《黒》《黒》：このシグニをトラッシュから場に出す。この能力はあなたの場にカード名に《ヨグソトス》を含むシグニがある場合にしか使用できない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetTiming(TIMING_ATTACK)
  e1:SetCondition(function(e,tp) return Duel.GetMatchingGroup(function(x) return aux.NameHas(x,"ヨグソトス") end,tp,LOCATION_TRASH,0,nil):GetCount()>0 end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,tp,LOCATION_TRASH,0,nil)
    Duel.SetSelectCheck(function(sg) return sg:GetCount()==0 or (sg:GetCount()==4 and aux.DistinctLevels(sg)) end)
    local pick=Duel.SelectCards(tp,g,0,4)
    if pick:GetCount()<4 then return end
    Duel.SendToDeckBottom(pick,true)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-7000) end  -- [まで]
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_TRASH)
  e2:SetEnaCost("{B}{B}")
  e2:SetTiming(TIMING_ATTACK)
  e2:SetCondition(function(e,tp) return Duel.GetMatchingGroup(function(x) return aux.NameHas(x,"ヨグソトス") end,tp,LOCATION_SZONE,0,nil):GetCount()>0 end)
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_TRASH) then Duel.PutOnField(h,tp) end
  end)
  c:RegisterEffect(e2)
end
