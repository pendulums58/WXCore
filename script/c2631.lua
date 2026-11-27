-- WX13-060 ストレンジ・カインド
-- 以下の２つから１つを選ぶ。あなたのセンタールリグのレベルが４以上の場合、代わりに２つまで選ぶ。
-- ①このターン、対戦相手のシグニのパワーが０以下になったとき、カードを１枚引く。
-- ②対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーをあなたの場にある＜毒牙＞のシグニのレベルを合計した数だけ－1000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local m=0
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    for _,i in ipairs(Duel.SelectModes(tp,1,(lc and lc:GetLevel()>=4) and 2 or 1,aux.Stringid(id,0),aux.Stringid(id,1))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()&2~=0 then Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m&1~=0 then
      -- [の間] 「このターン」 파워 0 이하가 되어 룰로 바니시되었을 때(근사)
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
      e1:SetCode(EVENT_BANISHED)
      e1:SetCondition(function(e2,tp2,eg,ep,ev,re,r) return eg:GetFirst():GetOwner()~=tp and r&REASON_RULE~=0 end)
      e1:SetOperation(function() Duel.Draw(tp,1) end)
      e1:SetReset(RESET_PHASE+PHASE_END)
      Duel.RegisterEffect(e1,tp)
    end
    if m&2~=0 then
      local tc=Duel.GetFirstTarget()
      local n=0
      for x in Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_DOKUGA)) end,tp,LOCATION_SZONE,0,nil):Iter() do n=n+x:GetLevel() end
      if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-1000*n) end
    end
  end)
  c:RegisterEffect(e1)
end
