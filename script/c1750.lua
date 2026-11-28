-- WDK13-022 コズミック・シンクロナイズ
-- 以下の２つから１つを選ぶ。
-- ①あなたの＜宇宙＞のシグニ１体を対象とし、それを場からトラッシュに置く。そうした場合、あなたのデッキの上からこの方法でトラッシュに置いたシグニのレベルと同じ枚数のカードを見る。その中から１枚を手札に加え、残りを好きな順番でデッキの一番下に置く。
-- ②【エナチャージ１】（あなたのデッキの一番上のカードをエナゾーンに置く）
local s,id=GetID()
s.space=aux.ClassFilter(0,RACE_UCHU)  -- ＜宇宙＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==0 then Duel.SelectTarget(tp,s.space,tp,LOCATION_SZONE,0,1,1,nil) end
  end)
  -- 장에 있을 때의 레벨(FAQ 2). 덱이 모자라면 있는 만큼(FAQ 1)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==1 then Duel.EnaCharge(tp,1) return end
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    local lv=tc:GetLevel()
    if Duel.SendToTrash(tc,REASON_EFFECT)==0 then return end
    local g=Duel.GetDecktopGroup(tp,lv)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local h=Duel.SelectCards(tp,g,1,1)
    if h:GetCount()>0 then Duel.SendToHand(h) end
    local rest=g:Filter(function(x) return x:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
  end)
  c:RegisterEffect(e1)
end
