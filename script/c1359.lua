-- WD22-036-G ペイン・バイ・ペイン
-- 以下の２つから１つを選ぶ。
-- ①あなたの＜遊具＞のシグニ１体を対象とし、それをバニッシュする。そうした場合、あなたのデッキの上からカードを５枚公開する。その中から＜遊具＞のシグニ１枚を手札に加えるか場に出す。残りを好きな順番でデッキの一番下に置く。
-- ②対象のあなたの＜遊戯＞のシグニ１体をバニッシュする。そうした場合、あなたのトラッシュから対象の＜遊具＞のシグニを５枚までデッキに加えてシャッフルする。
local s,id=GetID()
s.yugu=aux.ClassFilter(0,RACE_YUGU)  -- ＜遊具＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,s.yugu,tp,LOCATION_SZONE,0,1,1,nil)
    if e:GetLabel()==1 then Duel.SelectTarget(tp,s.yugu,tp,LOCATION_TRASH,0,0,5,nil) end
  end)
  e1:SetOperation(function(e,tp)
    local mine,back=nil,Group.CreateGroup()
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then
        if tc:IsLocation(LOCATION_TRASH) then back:AddCard(tc) else mine=tc end
      end
    end
    if not mine or Duel.Banish(mine)==0 then return end
    if e:GetLabel()==1 then
      Duel.SendToDeckShuffle(back,tp)
      return
    end
    local g=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,5))
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local tc=Duel.SelectCards(tp,g:Filter(s.yugu,nil),1,1):GetFirst()
    if tc then
      if Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))==0 then Duel.SendToHand(tc) else Duel.PutOnField(tc,tp) end
    end
    local rest=g:Filter(function(x) return x:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
  end)
  c:RegisterEffect(e1)
end
