-- WXK06-071 コードメイズ　サトリニ
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、このターンに対戦相手のカードがあなたの効果によって１枚以上デッキに移動していた場合、ターン終了時まで、それのパワーを－5000する。４枚以上移動していた場合、代わりにターン終了時まで、それのパワーを－12000する。
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②対戦相手は手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local n=Duel.GetDeckMovedCount(tp)
      if n>=4 then aux.AddPower(e,tc,-12000) elseif n>=1 then aux.AddPower(e,tc,-5000) end
    end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e9:SetOperation(function(e,tp,eg)
    if e:GetLabel()==0 then Duel.Draw(tp,1) else aux.Discard(1-tp,1) end
  end)
  c:RegisterEffect(e9)
end
