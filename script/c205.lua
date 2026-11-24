-- WD23-040-A ＰＲＡＮＫ
-- 以下の２つから１つを選ぶ。
-- ①あなたの＜トリック＞のシグニ１体を対象とし、それをバニッシュする。そうした場合、あなたのデッキの上からカードを３枚見る。その中からカード１枚を【トラップ】としてあなたのシグニゾーンに設置してもよい。その後、残りを好きな順番でデッキの一番下に置く。
-- ②対象のあなたの＜トリック＞のシグニ１体をバニッシュする。そうした場合、対象のあなたの【トラップ】１つを手札に加える。
local s,id=GetID()
s.trick=aux.ClassFilter(0,RACE_TRICK)  -- ＜トリック＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,s.trick,tp,LOCATION_SZONE,0,1,1,nil)
    if e:GetLabel()==1 then Duel.SelectTarget(tp,nil,tp,LOCATION_TRAP,0,1,1,nil) end
  end)
  -- 자기 시그니를 바니시하지 못하면 뒷부분은 하지 않는다
  e1:SetOperation(function(e,tp)
    local mine,tr
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then
        if tc:IsLocation(LOCATION_TRAP) then tr=tc else mine=tc end
      end
    end
    if not mine or Duel.Banish(mine)==0 then return end
    if e:GetLabel()==1 then
      if tr then Duel.SendToHand(tr) end  -- 상대에게 보이지 않는다(FAQ 4)
      return
    end
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local tc=Duel.SelectCards(tp,g,0,1):GetFirst()
    if tc then Duel.SetTrap(tc,tp) end
    local rest=g:Filter(function(x) return x:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
  end)
  c:RegisterEffect(e1)
end
