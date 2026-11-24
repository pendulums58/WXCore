-- WD20-018 創造
-- 以下の２つから１つを選ぶ。
-- ①あなたの＜英知＞のシグニ１体を対象とし、それをバニッシュする。そうした場合、あなたのデッキの上からカードを４枚見て、その中から＜英知＞のシグニ１枚を公開し手札に加える。残りを好きな順番でデッキの一番下に置く。
-- ②あなたのライフクロスが０枚の場合、あなたのすべてのシグニを場からトラッシュに置いてもよい。この方法で３体の＜英知＞のシグニがトラッシュに置かれた場合、あなたのデッキの一番上のカードをライフクロスに加える。
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
    if e:GetLabel()==0 then
      local tc=Duel.GetFirstTarget()
      -- 바니시되지 않았으면 뒷부분은 하지 않는다(FAQ 1)
      if not (tc and tc:IsRelateToEffect(e) and Duel.Banish(tc)>0) then return end
      local _,rest=aux.ExcavateToHand(tp,4,s.eichi,0,1,true)
      if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
      return
    end
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()>0 or g:GetCount()==0 or not Duel.SelectYesNo(tp) then return end
    local eichi=g:Filter(s.eichi,nil)
    Duel.SendToTrash(g,REASON_EFFECT)
    if eichi:Filter(function(x) return x:IsLocation(LOCATION_TRASH) end,nil):GetCount()==3 then
      Duel.SendToLife(Duel.GetDecktopGroup(tp,1))
    end
  end)
  c:RegisterEffect(e1)
end
