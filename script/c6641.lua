-- WXK06-026 ネクスト・フューチャー
-- 次のアタックフェイズの後に、追加のアタックフェイズを加える。この方法で加えたアタックフェイズ開始時、あなたのすべてのシグニをアップする。
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②対戦相手のレベル３以下のシグニ１体を対象とし、それを手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  -- 「追加のアタックフェイズを加える」는 아직(근사: 이 턴 어택 페이즈 개시 시에 모든 시그니를 업)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
    e1:SetCountLimit(1)
    e1:SetCondition(function() return Duel.GetTurnPlayer()==tp end)
    e1:SetOperation(function() local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil) if g:GetCount()>0 then Duel.Up(g) end end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e9:SetOperation(function(e,tp,eg)
    if e:GetLabel()==0 then Duel.Draw(tp,1) return end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e9)
end
