-- WX11-029 コードハート　Ｍ・Ｐ・Ｐ
-- 【出】：あなたのトラッシュからスペルを３枚まで対象とし、それらをこのカードの下に置く。
-- 【常】：あなたのシグニ１体がバニッシュされる場合、代わりにこのシグニの下からスペル２枚をトラッシュに置いてもよい。
-- 【起】《スペルカットインアイコン》このシグニの下からスペル１枚をトラッシュに置く：スペル１つを対象とし、それの効果を打ち消す。
-- ライフバースト：手札からスペルを好きな枚数捨てる。その後、この方法で捨てたスペル１枚につき対戦相手のシグニ１体を対象とし、それらをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_SPELL) end,tp,LOCATION_TRASH,0,0,3,nil)
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    local h=e:GetHandler()
    if g:GetCount()>0 and h:IsLocation(LOCATION_SZONE) then Duel.PutUnder(h,g) end
  end)
  c:RegisterEffect(e1)
  -- 【常】 「バニッシュされる場合、代わりに下からスペル２枚」는 아직(근사 없음)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_SZONE)
  e2:SetTiming(TIMING_CUTIN)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local u=e:GetHandler():GetUnderGroup():Filter(function(x) return x:IsType(TYPE_SPELL) end,nil)
    if chk==0 then return u:GetCount()>0 and Duel.GetCutinSpell()~=nil end
    Duel.SendToTrash(Duel.SelectCards(tp,u,1,1),REASON_COST)
  end)
  e2:SetOperation(function(e,tp)
    Duel.NegateSpell()
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_SPELL) end,tp,LOCATION_HAND,0,nil)
    local d=Duel.SelectCards(tp,g,0,g:GetCount())
    local n=d:GetCount()>0 and Duel.SendToTrash(d,REASON_EFFECT+REASON_DISCARD) or 0
    if n==0 then return end
    local t=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,n,n,nil)
    if t:GetCount()>0 then Duel.Banish(t) end
  end)
  c:RegisterEffect(e3)
end
