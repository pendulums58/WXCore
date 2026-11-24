-- WDK06-C20 リサイクル・デッズ
-- 以下の２つから１つを選ぶ。
-- ①あなたの＜武勇＞のシグニ１体を対象とし、それを場からトラッシュに置く。そうした場合、あなたのデッキの上からカードを２枚トラッシュに置く。その後、あなたのトラッシュから＜武勇＞のシグニ１枚を対象とし、それを場に出す。
-- ②【エナチャージ１】（あなたのデッキの一番上のカードをエナゾーンに置く）
local s,id=GetID()
s.buyu=aux.ClassFilter(0,RACE_BUYU)  -- ＜武勇＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==0 then Duel.SelectTarget(tp,s.buyu,tp,LOCATION_SZONE,0,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==1 then
      Duel.EnaCharge(tp,1)
      return
    end
    -- 내 시그니를 놓지 못하면 뒷부분은 하지 않는다(FAQ 1)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and Duel.SendToTrash(tc,REASON_EFFECT)>0) then return end
    local g=Duel.GetDecktopGroup(tp,2)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    -- 방금 놓은 시그니나 덱에서 놓인 시그니도 고를 수 있다(FAQ 2)
    local x=Duel.SelectTarget(tp,s.buyu,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if x then Duel.PutOnField(x,tp) end
  end)
  c:RegisterEffect(e1)
end
