-- WX12-Re21 トーチュン・ウィップ
-- 以下の２つから１つを選ぶ。
-- ①あなたの白のシグニ１体を対象とし、それをバニッシュする。そうした場合、あなたのデッキから白のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- ②対象のあなたの黒のシグニ１体をバニッシュする。そうした場合、ターン終了時まで、対象の対戦相手のシグニ１体のパワーを－7000する。
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
    local col=e:GetLabel()==0 and COLOR_WHITE or COLOR_BLACK
    s.a=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(col) end,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    s.b=e:GetLabel()==1 and Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() or nil
  end)
  e1:SetOperation(function(e,tp)
    if not (s.a and s.a:IsRelateToEffect(e)) or Duel.Banish(s.a)==0 then return end
    if e:GetLabel()==0 then aux.SearchToHand(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_WHITE) end,1)
    elseif s.b and s.b:IsRelateToEffect(e) then aux.AddPower(e,s.b,-7000) end
  end)
  c:RegisterEffect(e1)
end
