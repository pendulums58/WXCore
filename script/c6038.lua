-- WXEX1-04 快抱の使者　サシェ
-- 【自】《ターン１回》：あなたのターンの間、あなたのレゾナ１体が場に出たとき、以下の３つから１つを選ぶ。
-- ①カードを１枚引き、【エナチャージ１】をする。
-- ②対戦相手のシグニ１体を対象とし、それを手札に戻す。
-- ③ターン終了時まで、そのレゾナは「【常】：バニッシュされない。」を得る。
-- 【起】《アタックフェイズアイコン》《コインアイコン》《コインアイコン》：ターン終了時まで、対戦相手のすべてのシグニは「【常】：あなたが《無》《無》を支払わないかぎりアタックできない。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg)
    return Duel.GetTurnPlayer()==tp and eg:Filter(function(x) return x:GetControler()==tp and x:IsType(TYPE_RESONA) end,nil):GetCount()>0
  end)
  e1:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2)))
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==1 then Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp,eg)
    local m=e:GetLabel()
    if m==0 then
      Duel.Draw(tp,1)
      Duel.EnaCharge(tp,1)
    elseif m==1 then
      local tc=Duel.GetFirstTarget()
      if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
    else
      local rc=eg:Filter(function(x) return x:GetControler()==tp and x:IsType(TYPE_RESONA) and x:IsLocation(LOCATION_SZONE) end,nil):GetFirst()
      if rc then
        -- [まで] 「【常】：バニッシュされない。」を得る
        local g=Effect.CreateEffect(e:GetHandler())
        g:SetType(EFFECT_TYPE_SINGLE)
        g:SetCode(EFFECT_CANNOT_BANISH)
        g:SetReset(RESET_PHASE+PHASE_END)
        rc:GrantEffect(g)
      end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetTiming(TIMING_ATTACK)
  e2:SetCoinCost(2)
  e2:SetOperation(function(e,tp)
    -- [の間] 「あなたが《無》《無》を支払わないかぎりアタックできない。」(근사: 어택할 때 낼지 묻고 안 내면 그 어택을 무효)
    local ef=Effect.CreateEffect(e:GetHandler())
    ef:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    ef:SetCode(EVENT_ATTACK)
    ef:SetCondition(function(e2,tp2,eg) local a=eg:GetFirst() return a and a:IsSigni() and a:GetControler()==1-tp end)
    ef:SetOperation(function()
      local p=1-tp
      if Duel.CanPayEna(p,"{C}{C}") and Duel.SelectYesNo(p) then
        Duel.SendToTrash(Duel.SelectEnaCost(p,"{C}{C}"),REASON_COST)
      else
        Duel.NegateAttack()
      end
    end)
    ef:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(ef,tp)
  end)
  c:RegisterEffect(e2)
end
