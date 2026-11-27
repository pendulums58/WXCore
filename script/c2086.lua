-- WX05-023 羅原　Ｕ
-- 【常】：このシグニはアタックできない。
-- 【常】：このシグニのパワーはこのシグニの下にあるカード１枚につき＋2000される。
-- 【出】：あなたのトラッシュから《羅原　Ｕ》以外の＜原子＞のシグニ３枚を対象とし、それらをこのシグニの下に置く。そうしない場合、このシグニを場からトラッシュに置く。
-- 【起】《ダウン》：このシグニの下からカード１枚を対象とし、それを手札に加える。その後、このシグニの下にカードが無い場合、対戦相手のシグニ１体を対象とし、このシグニとそれをバニッシュする。
-- ライフバースト：あなたのトラッシュからスペル１枚と＜原子＞のシグニ１枚を対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 둘
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_CANNOT_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_UPDATE_POWER)
  e2:SetRange(LOCATION_SZONE)
  e2:SetValue(function(e) return 2000*e:GetHandler():GetUnderGroup():GetCount() end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  -- 3장을 다 고르지 못하면 하나도 고르지 않는다
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end)(x) and not x:IsCardName(id) end,tp,LOCATION_TRASH,0,3,3,nil)
  end)
  e3:SetOperation(function(e,tp)
    local h=e:GetHandler()
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()==3 and h:IsLocation(LOCATION_SZONE) then
      Duel.PutUnder(h,g)
    elseif h:IsLocation(LOCATION_SZONE) then
      Duel.SendToTrash(h,REASON_EFFECT)
    end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_IGNITION)
  e4:SetDescription(aux.Ability(id,3))
  e4:SetRange(LOCATION_SZONE)
  e4:SetCost(aux.SelfDownCost)
  e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local x=Duel.SelectCards(tp,e:GetHandler():GetUnderGroup(),1,1):GetFirst()
    e:SetLabelObject(x)
  end)
  e4:SetOperation(function(e,tp)
    local h,x=e:GetHandler(),e:GetLabelObject()
    if x then Duel.SendToHand(x) end
    if not h:IsLocation(LOCATION_SZONE) or h:GetUnderGroup():GetCount()>0 then return end
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    local g=Group.CreateGroup()
    g:AddCard(h)
    if tc then g:AddCard(tc) end
    Duel.Banish(g)
  end)
  c:RegisterEffect(e4)
  local e5=Effect.CreateEffect(c)
  e5:SetType(EFFECT_TYPE_LIFEBURST)
  e5:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_SPELL) end,tp,LOCATION_TRASH,0,1,1,nil)
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e5:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e5)
end
