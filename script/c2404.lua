-- WX10-029 極剣　ロクケイ
-- 【常】：このシグニのパワーはあなたの場にある＜ウェポン＞のシグニ１体につき＋5000される。
-- 【常】：このシグニがアタックしたとき、パワーがこのシグニのパワーの半分以下の対戦相手のシグニ１体を対象とし、それを手札に戻す。　　　　　　　　　　　　　
-- 【出】《赤》：あなたのデッキから＜ウェポン＞のシグニ１枚を探して場に出し、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetValue(function(e) return 5000*Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_WEAPON)) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount() end)
  c:RegisterEffect(e1)
  -- 【常】이라 적혀 있지만 어택했을 때의 처리
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetAbilityType(ABILITY_CONTINUOUS)
  e2:SetCode(EVENT_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local half=math.floor(e:GetHandler():GetPower()/2)
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=half end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetEnaCost("{R}")
  e3:SetOperation(function(e,tp)
    local x=aux.Search(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_WEAPON)) end,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e3)
end
