-- SP27-009 快睡の夢魔　サクバス（セレクターズパック vol.17）
-- 【起】《ダウン》：あなたのデッキの上からカードを３枚見る。その中から＜天使＞か＜悪魔＞のシグニ１枚を公開し手札に加え、残りを好きな順番でデッキの一番下に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  -- 있어도 넣지 않아도 된다(FAQ 1)
  e1:SetOperation(function(e,tp)
    local _,rest=aux.ExcavateToHand(tp,3,function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI) or x:IsClass(0,RACE_AKUMA)) end,0,1,true)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
  end)
  c:RegisterEffect(e1)
end
