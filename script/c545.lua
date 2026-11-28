-- SP26-007 天変地威（「Lostorage incited WIXOSS 6」 初回特典）
-- 対戦相手のターンの間、このアーツの使用コストは《赤×3》になる。
-- あなたのデッキをシャッフルし一番上を公開する。それがシグニの場合、それを場に出す。それが＜宇宙＞のシグニの場合、追加でこのカードをルリグデッキに戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) if Duel.GetTurnPlayer()~=tp then return "{R}{R}{R}" end return base end)
  -- 레벨·리미트를 넘어 내지 못해도 ＜宇宙＞면 돌아간다(FAQ 1·2)
  e1:SetOperation(function(e,tp)
    aux.ShuffleDeck(tp)
    local g=Duel.GetDecktopGroup(tp,1)
    local x=g:GetFirst()
    if not x then return end
    Duel.RevealCards(g)
    if not x:IsSigni() then return end
    local uchu=x:IsClass(0,RACE_UCHU)
    Duel.PutOnField(x,tp)
    local me=e:GetHandler()
    if uchu and me:IsLocation(LOCATION_CHECK) then Duel.SendToLrigDeck(me) end
  end)
  c:RegisterEffect(e1)
end
