-- WXK07-029 羅菌姫　プロテイン
-- 【自】：各アタックフェイズ開始時、表記されているパワーと異なるパワーのあなたの＜微菌＞のシグニ１体を対象とし、ターン終了時まで、それは「【常】：対戦相手の効果によって、バニッシュされず手札に戻らない。」を得る。
-- 【出】《緑》：あなたのエナゾーンから無色ではないシグニ１枚を対象とし、それを手札に加える。
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②対戦相手のパワー10000以上のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_BIKIN) end)(x) and x:GetPower()~=x:GetBasePower() end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      -- [まで] ターン終了時まで
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_BANISH_IMMUNE)
      e1:SetValue(function(e,sc,sp) return sp~=tc:GetControler() end)
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:GrantEffect(e1)
      aux.GrantKeyword(e,tc,EFFECT_NO_BOUNCE)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{G}")
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetColor()~=0 end,tp,LOCATION_ENA,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToHand(tc)
    end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e9:SetOperation(function(e,tp,eg)
    if e:GetLabel()==0 then Duel.Draw(tp,1) return end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=10000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e9)
end
