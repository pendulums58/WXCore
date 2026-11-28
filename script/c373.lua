-- PR-K049 エルフの聖者　セイラ（カードゲーマーvol.45 付録）
-- 【自】：このシグニがアタックしたとき、あなたと対戦相手のデッキの一番下のカードをトラッシュに置く。その後、この方法でトラッシュに置かれたシグニのレベルの合計が６以上の場合、ターン終了時まで、このシグニの正面のシグニのパワーを－5000する。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local g=Group.CreateGroup()
    for p=0,1 do g:Merge(Duel.GetDeckbottomGroup(p,1)) end
    if g:GetCount()==0 then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    local n=0
    for x in g:Iter() do if x:IsSigni() then n=n+x:GetLevel() end end
    local f=e:GetHandler():GetFrontCard()
    if n>=6 and f then aux.AddPower(e,f,-5000) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
