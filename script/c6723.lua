-- WXK07-025 羅原姫 Mdia
-- 【自】：このシグニがアタックしたとき、対戦相手のパワー3000以下のシグニ１体を対象とし、あなたのセンタールリグのレベルが対戦相手のセンタールリグ以下の場合、それをバニッシュする。
-- 【自】：このシグニがアタックしたとき、あなたのセンタールリグのレベルが対戦相手のセンタールリグより低い場合、カードを１枚引き、ターン終了時まで、このシグニのパワーを＋7000する。
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②対戦相手のパワー7000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=3000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      if Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst():GetLevel()<=Duel.GetMatchingGroup(nil,1-tp,LOCATION_LRIG,0,nil):GetFirst():GetLevel() then Duel.Banish(tc) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetOperation(function(e,tp,eg)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst():GetLevel()<Duel.GetMatchingGroup(nil,1-tp,LOCATION_LRIG,0,nil):GetFirst():GetLevel() then
      Duel.Draw(tp,1)
      local h=e:GetHandler()
      if h:IsLocation(LOCATION_SZONE) then aux.AddPower(e,h,7000) end
    end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e9:SetOperation(function(e,tp,eg)
    if e:GetLabel()==0 then Duel.Draw(tp,1) return end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=7000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e9)
end
