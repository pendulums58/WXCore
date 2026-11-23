-- WDK08-L07 血晶拡充
-- 以下の２つから１つを選ぶ。
-- ①あなたのデッキから＜紅蓮＞のシグニを２枚まで探して公開し手札に加え、デッキをシャッフルする。
-- ②あなたのトラッシュから＜紅蓮＞のシグニを２枚まで対象とし、それらを手札に加える。
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
-- 모드는 쓸 때 정하고 바꿀 수 없다(FAQ 3). 둘 다 0~2장(FAQ 1·2)
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  local mode=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
  e:SetLabel(mode)
  if mode==1 then Duel.SelectTarget(tp,s.guren,tp,LOCATION_TRASH,0,0,2,nil) end
end
function s.op(e,tp)
  if e:GetLabel()==0 then
    aux.SearchToHand(tp,s.guren,2)
    return
  end
  for tc in Duel.GetTargets():Iter() do
    if tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end
end
