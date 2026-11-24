-- WD17-018 神流の一振
-- 以下の２つから１つを選ぶ。
-- ①《ライズアイコン》を持たないあなたの＜武勇＞のシグニ１体を対象とし、それをバニッシュする。そうした場合、あなたのデッキから《ライズアイコン》を持つ＜武勇＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- ②対象のあなたの《ライズアイコン》を持つ＜武勇＞のシグニ１体をバニッシュする。そうした場合、対象の対戦相手のパワー12000以下のシグニ１体をバニッシュする。
local s,id=GetID()
s.buyu=aux.ClassFilter(0,RACE_BUYU)
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local rise=e:GetLabel()==1
    Duel.SelectTarget(tp,function(x) return s.buyu(x) and x:HasRiseIcon()==rise end,tp,LOCATION_SZONE,0,1,1,nil)
    if rise then Duel.SelectTarget(tp,s.low,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  -- 자기 시그니를 바니시하지 못하면 뒷부분은 하지 않는다(FAQ 1)
  e1:SetOperation(function(e,tp)
    local mine,opp
    for tc in Duel.GetTargets():Iter() do
      if tc:GetControler()==tp then mine=tc else opp=tc end
    end
    if not (mine and mine:IsRelateToEffect(e) and Duel.Banish(mine)>0) then return end
    if e:GetLabel()==0 then
      aux.SearchToHand(tp,function(x) return s.buyu(x) and x:HasRiseIcon() end,1)
    elseif opp and opp:IsRelateToEffect(e) and s.low(opp) then
      Duel.Banish(opp)
    end
  end)
  c:RegisterEffect(e1)
end
function s.low(c) return c:IsSigni() and c:GetPower()<=12000 end
