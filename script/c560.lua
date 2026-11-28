-- SP27-015 コードイート　トンカツ（セレクターズパック vol.19）
-- 【起】《メインフェイズアイコン》《アタックフェイズアイコン》《緑×0》：場にあるこのシグニを対象のあなたの他のシグニ１体の【アクセ】にする。そうした場合、このシグニに付いていた【アクセ】１枚を対象のあなたのシグニ１体に付けてもよい。
-- 【常】：これにアクセされているシグニのパワーを＋1000する。
-- 【常】：これにアクセされているシグニは「【起】《ターン１回》《メインフェイズアイコン》《アタックフェイズアイコン》あなたの【アクセ】２枚をトラッシュに置く：対戦相手のシグニ１体を対象とし、それをバニッシュする。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x~=e:GetHandler() end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and h:IsLocation(LOCATION_SZONE)) then return end
    local mine=Duel.GetMatchingGroup(function(a) return a:GetAcceHost()==h end,tp,LOCATION_ACCE,0,nil):GetFirst()
    if not Duel.Acce(h,tc) then return end
    -- 붙어 있던 【アクセ】는 대상인 내 시그니 1체에 붙여도 된다
    if mine and mine:IsLocation(LOCATION_ACCE+LOCATION_TRASH) and Duel.SelectYesNo(tp) then
      local x=Duel.SelectTarget(tp,function(y) return y:IsSigni() and y:GetAcceHost()==nil end,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
      if x then Duel.Acce(mine,x) end
    end
  end)
  c:RegisterEffect(e1)
  -- [の間] 【常】 이것이 붙은 시그니
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_UPDATE_POWER)
  e2:SetRange(LOCATION_ACCE)
  e2:SetTargetRange(LOCATION_SZONE,0)
  e2:SetTarget(function(e,x) return x==e:GetHandler():GetAcceHost() end)
  e2:SetValue(1000)
  c:RegisterEffect(e2)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_IGNITION)
  g:SetDescription(aux.Ability(id,2))
  g:SetRange(LOCATION_SZONE)
  g:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  g:SetCountLimit(1)
  g:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local a=Duel.GetMatchingGroup(nil,tp,LOCATION_ACCE,0,nil)
    if chk==0 then return a:GetCount()>=2 end
    Duel.SendToTrash(Duel.SelectCards(tp,a,2,2),REASON_COST)
  end)
  g:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  g:SetOperation(aux.BanishOp)
  -- [の間] 【常】
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EFFECT_GRANT)
  e3:SetRange(LOCATION_ACCE)
  e3:SetTargetRange(LOCATION_SZONE,0)
  e3:SetTarget(function(e,x) return x==e:GetHandler():GetAcceHost() end)
  e3:SetLabelObject(g)
  c:RegisterEffect(e3)
end
