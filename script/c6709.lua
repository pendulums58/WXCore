-- WXK07-006 華代・爾彩焔
-- 【常】：あなたのグロウフェイズをスキップする。
-- 【起】《ターン１回》＜原子＞のシグニ１体を場からトラッシュに置く：カードを１枚引く。
-- 【起】《ゲーム１回》《赤》《赤》《赤》：あなたのルリグデッキが２枚以下の場合、《コインアイコン》《コインアイコン》を得る。
-- 【起】《ゲーム１回》バーニング《コインアイコン×0》＜原子＞のシグニ３体を場からトラッシュに置く：対戦相手のライフクロス１枚をクラッシュする。この効果でクラッシュされたカードのライフバーストは発動しない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_SKIP_GROW)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(1,0)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_GENSHI) end)(x) and x~=e:GetHandler() end,tp,LOCATION_SZONE,0,nil)
    if chk==0 then return g:GetCount()>=1 end
    local sg=Duel.SelectCards(tp,g,1,1)
    
    Duel.SendToTrash(sg,REASON_COST)
  end)
  e2:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(1,true)
  e3:SetEnaCost("{R}{R}{R}")
  e3:SetOperation(function(e,tp,eg)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_LDECK,0,nil):GetCount()<=2 then Duel.AddCoin(tp,2) end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_IGNITION)
  e4:SetDescription(aux.Ability(id,3))
  e4:SetRange(LOCATION_LRIG)
  e4:SetCountLimit(1,true)
  e4:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_GENSHI) end)(x) and x~=e:GetHandler() end,tp,LOCATION_SZONE,0,nil)
    if chk==0 then return g:GetCount()>=3 end
    local sg=Duel.SelectCards(tp,g,3,3)
    
    Duel.SendToTrash(sg,REASON_COST)
  end)
  e4:SetOperation(function(e,tp,eg)
    Duel.Crush(1-tp,1,false,true)
  end)
  c:RegisterEffect(e4)
end
