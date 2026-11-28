-- WDK13-008 オリオンズ・バブル
-- 以下の２つから１つを選ぶ。
-- ①あなたのトラッシュから＜宇宙＞のシグニを、レベルの合計が７になるように３枚まで対象とし、それらを手札に加える。
-- ②あなたのトラッシュから＜宇宙＞のシグニを、レベルの合計が１２になるように５枚まで対象とし、対戦相手の場にキーがある場合、それらを手札に加える。
local s,id=GetID()
s.space=aux.ClassFilter(0,RACE_UCHU)  -- ＜宇宙＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  -- 「合計が７になるように」: 고른 카드의 레벨 합계가 딱 그 값(0장도 된다)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local n,m=7,3
    if e:GetLabel()==1 then n,m=12,5 end
    Duel.SetSelectCheck(function(sg) local lv=0 for x in sg:Iter() do lv=lv+x:GetLevel() end return sg:GetCount()==0 or lv==n end)
    Duel.SelectTarget(tp,s.space,tp,LOCATION_TRASH,0,0,m,nil)
  end)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==1 and Duel.GetMatchingGroup(nil,tp,0,LOCATION_KEY,nil):GetCount()==0 then return end
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e1)
end
