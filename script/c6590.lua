-- WXK05-048 フィフス・テンプト
-- このスペルの使用コストはあなたのセンタールリグのレベル１につき《無×1》減る。
-- このスペルの使用コストの合計は０以下にならない。
-- 以下の５つから１つを選ぶ。
-- ①あなたのデッキからシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- ②対戦相手のパワー8000以下のシグニ１体を対象とし、それをバニッシュする。
-- ③カードを２枚引き、手札を１枚捨てる。
-- ④対戦相手のパワー12000以上のシグニ１体を対象とし、それをバニッシュする。
-- ⑤あなたのトラッシュからシグニ１枚を対象とし、それを場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3),aux.Stringid(id,4))) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local m=e:GetLabel()
    if m==1 then Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=8000 end,tp,0,LOCATION_SZONE,1,1,nil)
    elseif m==3 then Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=12000 end,tp,0,LOCATION_SZONE,1,1,nil)
    elseif m==4 then Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp,eg)
    local m=e:GetLabel()
    if m==0 then aux.SearchToHand(tp,Card.IsSigni,1) return end
    if m==2 then Duel.Draw(tp,2) aux.Discard(tp,1) return end
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    if m==1 and tc:GetPower()<=8000 then Duel.Banish(tc) end
    if m==3 and tc:GetPower()>=12000 then Duel.Banish(tc) end
    if m==4 then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e1)
  -- 합계는 0 이하로 되지 않는다(근사: 최소 《無》 1)
  aux.SetCostBy(e1,function(e,tp,base) local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() local n=math.min(5,lc and lc:GetLevel() or 0) return Duel.ReduceCost(base,"{C}",n) end)
end
