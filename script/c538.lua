-- WD18-018 千切
-- 以下の２つから１つを選ぶ。
-- ①あなたの＜調理＞のシグニ１体を対象とし、それをバニッシュする。そうした場合、あなたのデッキから＜調理＞のシグニ１枚を探してエナゾーンに置き、デッキをシャッフルする。
-- ②対象のあなたの＜調理＞のシグニ１体をバニッシュする。そうした場合、対象の対戦相手のパワー15000以上のシグニ１体をバニッシュする。
local s,id=GetID()
s.chouri=aux.ClassFilter(0,RACE_CHOURI)  -- ＜調理＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  -- ②는 내 시그니와 상대 시그니를 처리 직전에 함께 고른다(FAQ 1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,s.chouri,tp,LOCATION_SZONE,0,1,1,nil)
    if e:GetLabel()==1 then
      Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=15000 end,tp,0,LOCATION_SZONE,1,1,nil)
    end
  end)
  -- 자기 시그니를 바니시하지 못하면 뒷부분은 하지 않는다(FAQ 2)
  e1:SetOperation(function(e,tp)
    local mine,opp
    for tc in Duel.GetTargets():Iter() do
      if tc:GetControler()==tp then mine=tc else opp=tc end
    end
    if not (mine and mine:IsRelateToEffect(e) and Duel.Banish(mine)>0) then return end
    if e:GetLabel()==0 then
      Duel.ConfirmCards(tp,Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil))
      local g=Duel.SelectCards(tp,Duel.GetMatchingGroup(s.chouri,tp,LOCATION_MDECK,0,nil),0,1)
      if g:GetCount()>0 then Duel.SendToEna(g) end
      Duel.SendToDeckShuffle(Group.CreateGroup(),tp)
    elseif opp and opp:IsRelateToEffect(e) then
      Duel.Banish(opp)
    end
  end)
  c:RegisterEffect(e1)
end
