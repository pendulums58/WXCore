-- WXK01-080 狂想の滅炎
-- 以下の２つから１つを選ぶ。
-- ①対戦相手のパワー10000以下のシグニ１体を対象とし、それをバニッシュする。　
-- ②ターン終了時まで、あなたのすべてのシグニのパワーを＋3000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==0 then Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=10000 end,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp,eg)
    if e:GetLabel()==1 then
      -- [まで] ターン終了時まで. 처리할 때 장에 있는 것만(FAQ 1)
      for x in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do aux.AddPower(e,x,3000) end
      return
    end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:GetPower()<=10000 then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
end
