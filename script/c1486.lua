-- WX18-002 哀罪の駄姫　グズ子
-- 【自】《ターン１回》：対戦相手のアタックフェイズの間、あなたの＜遊具＞のシグニ１体がバニッシュされたとき、あなたのデッキの一番上を公開する。それが＜遊具＞のシグニの場合、それを場に出してもよい。
-- 【出】：あなたのデッキから＜遊具＞のシグニ１枚を探して場に出し、デッキをシャッフルする。
-- 【起】ダイレクト《ターン１回》《コインアイコン》《コインアイコン》：このターン、対戦相手がダメージを受けたとき、対戦相手のライフクロス１枚をクラッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return Duel.GetTurnPlayer()~=tp and Duel.GetPhase()==PHASE_ATTACK and x:GetOwner()==tp and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end)(x) end)
  e1:SetOperation(function(e,tp)
    local x=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not x then return end
    Duel.RevealCards(Group.CreateGroup(x))
    if (function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end)(x) and Duel.SelectYesNo(tp) then Duel.PutOnField(x,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local x=aux.Search(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(1)
  e3:SetCoinCost(2)
  e3:SetOperation(function(e,tp)
    -- [の間] 「このターン」
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_DAMAGE)
    e1:SetCondition(function(e2,tp2,eg,ep) return ep~=tp end)
    e1:SetOperation(function() Duel.Crush(1-tp,1) end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e3)
end
