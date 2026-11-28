-- SPK01-02 魔界の詩文　ダンテ（パーティーパックVol.1）
-- 【出】：あなたの手札からカードを２枚までこのシグニの下に置く。
-- 【自】：このシグニが場を離れたとき、あなたのトラッシュからこのカードの下にあったカードを２枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local put={}  -- 【出】로 아래에 둔 카드
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  -- 0~2장(FAQ 2)
  e1:SetOperation(function(e,tp)
    put={}
    local h=e:GetHandler()
    local hand=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    if hand:GetCount()==0 or not h:IsLocation(LOCATION_SZONE) then return end
    local g=Duel.SelectCards(tp,hand,0,2)
    if g:GetCount()==0 then return end
    for x in g:Iter() do put[#put+1]=x end
    Duel.PutUnder(h,g)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_LEAVE_FIELD)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local was={}
    for _,x in ipairs(put) do was[x]=true end
    put={}
    Duel.SelectTarget(tp,function(x) return was[x] end,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e2)
end
