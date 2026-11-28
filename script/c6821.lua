-- WXK08-035 コードＶＬ　ドーラ
-- 【出】《白》：対戦相手のレベル２以下のシグニ１体を対象とし、それを手札に戻す。あなたの登録者数が１００万人を達成している場合、代わりに対戦相手のレベル３以下のシグニ１体を対象とし、それを手札に戻す。
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②対戦相手のレベル１以下のシグニ１体を対象とし、それを手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{W}")
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local lv=Duel.GetSubscribers(tp)>=100 and 3 or 2
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=lv end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToHand(tc)
    end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e9:SetOperation(function(e,tp,eg)
    if e:GetLabel()==0 then Duel.Draw(tp,1) return end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=1 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e9)
end
