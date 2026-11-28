-- SP27-004 大盾　スパルタン（セレクターズパック vol.16）
-- 【自】：このシグニがバニッシュされたとき、あなたのデッキの上からカードを３枚公開する。その中から＜アーム＞のシグニ１枚を場に出し、残りを好きな順番でデッキの一番下に置く。
-- 【出】：あなたのデッキの上からカードを３枚公開する。その中から＜ウェポン＞のシグニ１枚を場に出し、残りを好きな順番でデッキの一番下に置く。
-- ライフバースト：あなたのデッキから＜アーム＞か＜ウェポン＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- 둘 다 강제. 덱이 3장 미만이면 있는 만큼(FAQ 1·2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local cand=g:Filter(function(x) return x:IsSigni() and x:IsClass(0,RACE_ARM) end,nil)
    if cand:GetCount()>0 then Duel.PutOnField(Duel.SelectCards(tp,cand,1,1):GetFirst(),tp) end
    local rest=g:Filter(function(x) return x:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local cand=g:Filter(function(x) return x:IsSigni() and x:IsClass(0,RACE_WEAPON) end,nil)
    if cand:GetCount()>0 then Duel.PutOnField(Duel.SelectCards(tp,cand,1,1):GetFirst(),tp) end
    local rest=g:Filter(function(x) return x:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_ARM) or x:IsClass(0,RACE_WEAPON)) end,1)
  end)
  c:RegisterEffect(e3)
end
