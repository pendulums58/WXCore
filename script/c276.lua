-- PR-434 錯乱する所以（コロコロアニキ2017年秋号 付録）
-- 数字１つを宣言する。あなたのデッキの上からカードを５枚公開する。その中から宣言した数字と同じレベルを持つシグニを２枚まで手札に加え、残りをシャッフルしてデッキの一番下に置く。
-- ライフバースト：数字１つを宣言する。あなたのデッキの上からカードを５枚公開する。その中から宣言した数字と同じレベルを持つシグニを２枚まで手札に加え、残りをシャッフルしてデッキの一番下に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 4장 이하면 전부(FAQ 2)
  e1:SetOperation(function(e,tp)
    local lv=Duel.AnnounceNumber(tp,0,5)
    local g=Duel.GetDecktopGroup(tp,5)
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local h=Duel.SelectCards(tp,g:Filter(function(x) return x:IsSigni() and (x:GetLevel()==lv or x:HasKeyword(EFFECT_ANY_LEVEL)) end,nil),0,2)
    if h:GetCount()>0 then Duel.SendToHand(h) end
    local rest=g:Filter(function(x) return x:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(rest,true) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    local lv=Duel.AnnounceNumber(tp,0,5)
    local g=Duel.GetDecktopGroup(tp,5)
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local h=Duel.SelectCards(tp,g:Filter(function(x) return x:IsSigni() and (x:GetLevel()==lv or x:HasKeyword(EFFECT_ANY_LEVEL)) end,nil),0,2)
    if h:GetCount()>0 then Duel.SendToHand(h) end
    local rest=g:Filter(function(x) return x:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(rest,true) end
  end)
  c:RegisterEffect(e2)
end
