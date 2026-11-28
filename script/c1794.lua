-- WDK16-05S 凛サポーター　美兎＆楓
-- 【常】：このキーはあなたのセンタールリグが《静凛　レベル４》の場合にしか新たに場に出すことができない。
-- 【出】：対象の対戦相手のシグニ１体を手札に戻す。対象の対戦相手のシグニ１体をバニッシュする。登録者数を２０万人得る。
-- 【起】《アタックフェイズアイコン》《無》このキーを場からルリグトラッシュに置く：対象の対戦相手のシグニを２体までバニッシュする。ターン終了時まで、対象の対戦相手のセンタールリグ１体は「【常】：アタックできない。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetCode(EFFECT_CANNOT_PLAY)
  e1:SetCondition(function(e)
    local lc=Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_LRIG,0,nil):GetFirst()
    return not (lc and lc:IsCardName(1782))
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local a=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,a)
  end)
  -- 앞에 고른 것을 패로, 뒤에 고른 것을 바니시
  e2:SetOperation(function(e,tp)
    local first=Duel.GetFirstTarget()
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then
        if tc==first then Duel.SendToHand(tc) else Duel.Banish(tc) end
      end
    end
    Duel.AddSubscribers(tp,20)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_KEY)
  e3:SetTiming(TIMING_ATTACK)
  e3:SetEnaCost("{C}")
  e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) end
    Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
  end)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil)
    Duel.SelectTarget(tp,nil,tp,0,LOCATION_LRIG,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local g=Group.CreateGroup()
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then
        if tc:IsSigni() then g:AddCard(tc) else aux.GrantKeyword(e,tc,EFFECT_CANNOT_ATTACK) end  -- [まで] ターン終了時まで
      end
    end
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e3)
end
