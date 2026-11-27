-- WX16-Re01 スター・フェスティバル
-- 以下の２つから１つを選ぶ。
-- ①レゾナではないあなたのシグニ１体を対象とし、それをバニッシュする。そうした場合、あなたのデッキから＜宇宙＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- ②対象のあなたのレゾナ１体をバニッシュする。そうした場合、対象の対戦相手のレベル３以下のシグニ１体を手札に戻す。
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
    s.b=res and Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() or nil
  end)
  e1:SetOperation(function(e,tp)
    if not (s.a and s.a:IsRelateToEffect(e)) or Duel.Banish(s.a)==0 then return end
    if e:GetLabel()==0 then aux.SearchToHand(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_UCHU)) end,1) return end
    if s.b and s.b:IsRelateToEffect(e) then Duel.SendToHand(s.b) end
  end)
  c:RegisterEffect(e1)
end
