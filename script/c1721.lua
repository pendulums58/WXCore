-- WDK11-022 モーニング・コール
-- 以下の２つから１つを選ぶ。
-- ①あなたの＜英知＞のシグニ１体を対象とし、それを場からトラッシュに置く。そうした場合、あなたのデッキから＜英知＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- ②【エナチャージ１】（あなたのデッキの一番上のカードをエナゾーンに置く）
local s,id=GetID()
s.eichi=aux.ClassFilter(0,RACE_EICHI)  -- ＜英知＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==0 then Duel.SelectTarget(tp,s.eichi,tp,LOCATION_SZONE,0,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==1 then
      Duel.EnaCharge(tp,1)
      return
    end
    -- 내 시그니를 놓지 못하면 뒷부분은 하지 않는다
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and Duel.SendToTrash(tc,REASON_EFFECT)>0) then return end
    aux.SearchToHand(tp,s.eichi,1)
  end)
  c:RegisterEffect(e1)
end
