-- WX16-Re10 キャッチ・リリース
-- 以下の２つから１つを選ぶ。
-- ①対象のレゾナではないあなたのシグニ１体をバニッシュする。そうした場合、あなたのトラッシュから対象の＜凶蟲＞のシグニ１枚を手札に加える。
-- ②対象のあなたのレゾナ１体をバニッシュする。そうした場合、ターン終了時まで、対象の対戦相手のシグニ１体のパワーを－10000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local res=e:GetLabel()==1
    s.a=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsType(TYPE_RESONA)==res end,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    if res then s.b=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    else s.b=Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_KYOUCHU)) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst() end
  end)
  e1:SetOperation(function(e,tp)
    if not (s.a and s.a:IsRelateToEffect(e)) or Duel.Banish(s.a)==0 or not (s.b and s.b:IsRelateToEffect(e)) then return end
    if e:GetLabel()==0 then Duel.SendToHand(s.b) else aux.AddPower(e,s.b,-10000) end  -- [まで]
  end)
  c:RegisterEffect(e1)
end
