-- WX22-Re03 ゴースト・パーティー
-- 以下の２つから１つを選ぶ。
-- ①あなたの＜怪異＞のシグニ１体を対象とし、それをバニッシュする。そうした場合、あなたのデッキから＜怪異＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- ②対象のあなたの＜怪異＞のシグニ２体を場からトラッシュに置く。この方法でシグニ２体をトラッシュに置いた場合、対象の対戦相手のシグニ１体を手札に戻す。
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
    if e:GetLabel()==0 then
      s.a=Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_KAII)) end,tp,LOCATION_SZONE,0,1,1,nil)
      s.b=nil
    else
      s.a=Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_KAII)) end,tp,LOCATION_SZONE,0,2,2,nil)
      s.b=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    end
  end)
  e1:SetOperation(function(e,tp)
    local g=s.a:Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if e:GetLabel()==0 then
      if g:GetCount()>0 and Duel.Banish(g)>0 then aux.SearchToHand(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_KAII)) end,1) end
      return
    end
    if g:GetCount()==2 and Duel.SendToTrash(g,REASON_EFFECT)==2 and s.b and s.b:IsRelateToEffect(e) then Duel.SendToHand(s.b) end
  end)
  c:RegisterEffect(e1)
end
