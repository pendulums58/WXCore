-- WXK09-046 ＦＯＲＣＥＤ
-- 以下の２つから１つを選ぶ。
-- ①次のあなたのアタックフェイズ開始時、カードを２枚引く。
-- ②次のあなたのアタックフェイズ開始時、あなたのトラッシュに＜天使＞のシグニが１０枚以上ある場合、カードを３枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e1:SetOperation(function(e,tp,eg)
    local m=e:GetLabel()
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
    e1:SetCountLimit(1)
    e1:SetCondition(function() return Duel.GetTurnPlayer()==tp end)
    e1:SetOperation(function()
      if m==0 then Duel.Draw(tp,2) elseif Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_TENSHI) end,tp,LOCATION_TRASH,0,nil):GetCount()>=10 then Duel.Draw(tp,3) end
    end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
