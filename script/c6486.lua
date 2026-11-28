-- WXK04-030 血晶の紅雨
-- あなたの＜紅蓮＞のシグニ１体を対象とし、それを血晶武装［デッキ］し、デッキをシャッフルする。ターン終了時まで、あなたの血晶武装状態のすべてのシグニのパワーを＋5000し、それらは「【自】：このシグニがアタックしたとき、自身のパワー以下の対戦相手のシグニ１体を対象とし、それをバニッシュする。」を得る。
-- ライフバースト：どちらか１つを選ぶ。①対戦相手のパワー10000以上のシグニ１体を対象とし、それをバニッシュする。②あなたのデッキから＜紅蓮＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_GUREN) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.BloodArm(tp,tc,LOCATION_MDECK) end
    aux.ShuffleDeck(tp)
    -- 처리할 때 血晶武装状態인 것
    for x in Duel.GetMatchingGroup(function(y) return y:IsSigni() and y:IsBloodArmed() end,tp,LOCATION_SZONE,0,nil):Iter() do
      aux.AddPower(e,x,5000)
      local g=Effect.CreateEffect(e:GetHandler())
      g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
      g:SetDescription(aux.Stringid(id,0))
      g:SetCode(EVENT_ATTACK)
      g:SetTarget(function(e2,tp2,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return true end
        local pw=e2:GetHandler():GetPower()
        Duel.SelectTarget(tp2,function(y) return y:IsSigni() and y:GetPower()<=pw end,tp2,0,LOCATION_SZONE,1,1,nil)
      end)
      g:SetOperation(aux.BanishOp)
      g:SetReset(RESET_PHASE+PHASE_END)
      x:GrantEffect(g)
    end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e9:SetOperation(function(e,tp,eg)
    if e:GetLabel()==1 then aux.SearchToHand(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_GUREN) end,1) return end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=10000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e9)
end
