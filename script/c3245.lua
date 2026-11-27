-- WX22-022 伍ノ遊姫王　ノポポン
-- 【常】：このシグニはダウン状態でもアタックできる。
-- 【常】：各ターン、このシグニは自身のパワー10000につき一度までしかアタックできない。
-- 【常】：このシグニのパワーは30000より大きくならない。
-- 【自】：あなたの他のシグニ１体がアタックしたとき、ターン終了時まで、このシグニのパワーは＋5000される。
-- ライフバースト：あなたのデッキから異なる色を持つ＜遊具＞のシグニ２枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- 【常】 「ダウン状態でもアタック」·「パワー10000につき一度」·「30000より大きくならない」는 아직(근사 없음)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,3))
  e1:SetCode(EVENT_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()==tp and x:IsSigni() and x~=e:GetHandler() end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then aux.AddPower(e,h,5000) end  -- [まで]
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    local a=aux.Search(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end,1)
    local x=a:GetFirst()
    if x then a:Merge(aux.Search(tp,function(c) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end)(c) and c:GetColor()&x:GetColor()==0 end,1)) end
    if a:GetCount()>0 then Duel.RevealCards(a) Duel.SendToHand(a) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e2)
end
