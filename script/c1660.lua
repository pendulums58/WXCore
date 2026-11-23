-- WDK08-L20 血晶の斧撃
-- 以下の２つから１つを選ぶ。
-- ①対象のあなたの＜紅蓮＞のシグニ１体を場からトラッシュに置く。そうした場合、対象の対戦相手のパワー12000以下のシグニ１体をバニッシュする。
-- ②【エナチャージ１】
local s,id=GetID()
s.guren=aux.ClassFilter(0,RACE_GUREN)  -- ＜紅蓮＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(s.tg)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- ①은 내 시그니와 상대 시그니를 처리 직전에 함께 고른다(FAQ 1)
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  local mode=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
  e:SetLabel(mode)
  if mode==0 then
    Duel.SelectTarget(tp,s.guren,tp,LOCATION_SZONE,0,1,1,nil)
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=12000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end
end
function s.op(e,tp)
  if e:GetLabel()==1 then
    Duel.EnaCharge(tp,1)
    return
  end
  local mine, opp
  for tc in Duel.GetTargets():Iter() do
    if tc:GetControler()==tp then mine=mine or tc else opp=opp or tc end
  end
  -- 「そうした場合」: 내 ＜紅蓮＞을 트래시에 놓지 못하면 바니시하지 않는다(FAQ 2)
  if not (mine and mine:IsRelateToEffect(e) and Duel.SendToTrash(mine,REASON_EFFECT)>0) then return end
  if opp and opp:IsRelateToEffect(e) then Duel.Banish(opp) end
end
