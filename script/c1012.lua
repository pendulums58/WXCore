-- SPK01-07 獣爪一対（パーティーパックVol.3）
-- このアーツを使用する際、あなたのキー１枚を場からルリグトラッシュに置いてもよい。そうした場合、このアーツの使用コストは《緑×3》減る。
-- 以下の３つから２つまで選ぶ。
-- ①対戦相手のパワー12000以上のシグニ１体を対象とし、それをバニッシュする。
-- ②カードを２枚引く。
-- ③このターン、対戦相手のセンタールリグがアタックしたとき、そのアタックを無効にする。
local s,id=GetID()
function s.initial_effect(c)
  local key=nil  -- 선언 때 고른 키. 확정되면 루리그 트래시에
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetMinCost(function(e,tp,base)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_KEY,0,nil):GetCount()>0 then return Duel.ReduceCost(base,"{G}{G}{G}",1) end
    return base
  end)
  e1:SetDeclare(function(e,tp)
    key=nil
    local base=Duel.GetUseCost()
    local keys=Duel.GetMatchingGroup(nil,tp,LOCATION_KEY,0,nil)
    if keys:GetCount()>0 and (not Duel.CanPayEna(tp,base) or Duel.SelectYesNo(tp)) then
      key=Duel.SelectCards(tp,keys,1,1):GetFirst()
      Duel.SetUseCost(Duel.ReduceCost(base,"{G}{G}{G}",1))
    end
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if key then Duel.SendToLrigTrash(key,REASON_COST) end
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()&1~=0 then Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=12000 end,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m&1~=0 then
      local tc=Duel.GetFirstTarget()
      if tc and tc:IsRelateToEffect(e) and tc:GetPower()>=12000 then Duel.Banish(tc) end
    end
    if m&2~=0 then Duel.Draw(tp,2) end
    if m&4~=0 then
      -- [の間] 「このターン」
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
      e1:SetCode(EVENT_ATTACK)
      e1:SetCondition(function(e2,tp2,eg) local x=eg:GetFirst() return x:GetControler()~=tp and x:IsType(TYPE_LRIG) and x:IsLocation(LOCATION_LRIG) end)
      e1:SetOperation(function() Duel.NegateAttack() end)
      e1:SetReset(RESET_PHASE+PHASE_END)
      Duel.RegisterEffect(e1,tp)
    end
  end)
  c:RegisterEffect(e1)
end
