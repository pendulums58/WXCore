-- WDK08-Y20 斬衝
-- 以下の２つから１つを選ぶ。
-- ①あなたの＜水獣＞のシグニ１体を対象とし、それを場からトラッシュに置く。その後、この方法でトラッシュに置いたシグニのパワー以下の対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- ②【エナチャージ１】
local s,id=GetID()
s.suiju=aux.ClassFilter(0,RACE_SUIJU)  -- ＜水獣＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(s.mode)
  e1:SetTarget(s.tg)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
function s.mode(e,tp)
  e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1)))
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  local mode=e:GetLabel()
  if mode==0 then Duel.SelectTarget(tp,s.suiju,tp,LOCATION_SZONE,0,1,1,nil) end
end
function s.op(e,tp)
  if e:GetLabel()==1 then
    Duel.EnaCharge(tp,1)
    return
  end
  -- 「その後」의 대상은 트래시에 놓은 뒤 고른다. 놓지 못하면 바니시하지 않는다(FAQ 1)
  local mine=Duel.GetFirstTarget()
  if not (mine and mine:IsRelateToEffect(e)) then return end
  local pw=mine:GetPower()
  if Duel.SendToTrash(mine,REASON_EFFECT)==0 then return end
  local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=pw end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
  if tc then Duel.Banish(tc) end
end
