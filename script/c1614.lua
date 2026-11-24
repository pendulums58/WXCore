-- WDK05-R20 ＦＲＯＺＥＮ　ＦＩＮＧＥＲ
-- 以下の２つから１つを選ぶ。
-- ①対象のあなたの＜英知＞のシグニ１体を場からトラッシュに置く。そうした場合、対象の対戦相手の凍結状態のシグニ１体をバニッシュする。
-- ②【エナチャージ１】（あなたのデッキの一番上のカードをエナゾーンに置く）
local s,id=GetID()
s.eichi=aux.ClassFilter(0,RACE_EICHI)  -- ＜英知＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  -- ①은 두 시그니를 처리 직전에 함께 고른다(FAQ 1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==1 then return end
    Duel.SelectTarget(tp,s.eichi,tp,LOCATION_SZONE,0,1,1,nil)
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsFrozen() end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==1 then
      Duel.EnaCharge(tp,1)
      return
    end
    local mine,opp
    for tc in Duel.GetTargets():Iter() do
      if tc:GetControler()==tp then mine=mine or tc else opp=opp or tc end
    end
    -- 내 시그니를 놓지 못하면 뒷부분은 하지 않는다(FAQ 2)
    if not (mine and mine:IsRelateToEffect(e) and Duel.SendToTrash(mine,REASON_EFFECT)>0) then return end
    if opp and opp:IsRelateToEffect(e) then Duel.Banish(opp) end
  end)
  c:RegisterEffect(e1)
end
