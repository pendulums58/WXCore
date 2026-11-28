-- WXK01-110 バッド・スイッチ
-- 以下の２つから１つを選ぶ。
-- ①あなたのトラッシュから黒のシグニ１枚を対象とし、それを手札に加える。
-- ②対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－7000する。
-- （パワーが０以下のシグニはルールによってバニッシュされる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==0 then Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,tp,LOCATION_TRASH,0,1,1,nil)
    else Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      if e:GetLabel()==0 then Duel.SendToHand(tc) else aux.AddPower(e,tc,-7000) end
    end
  end)
  c:RegisterEffect(e1)
end
