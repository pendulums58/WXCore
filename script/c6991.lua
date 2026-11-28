-- WXK10-017 白夜の使者　サシェ＆ミュウ
-- 【出】：あなたのデッキの上からカードを３枚見る。それらを好きな順番でデッキの一番上に戻す。
-- 【起】《ターン１回》《白×0》：数字１つを宣言する。あなたのデッキの一番上を公開し、それが宣言した数字と同じレベルを持つシグニの場合、それを手札に加える。
-- 【起】《アタックフェイズアイコン》このキーを場からルリグトラッシュに置く：あなたのデッキの一番上を公開する。それがシグニの場合、それを場に出す。それの【出】能力は発動しない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()>1 then Duel.ConfirmCards(tp,g) aux.ToDeckTopInOrder(tp,g) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_KEY)
  e2:SetCountLimit(1)
  e2:SetOperation(function(e,tp,eg)
    local n=Duel.AnnounceNumber(tp,0,5)
    local g=Duel.GetDecktopGroup(tp,1)
    local x=g:GetFirst()
    if not x then return end
    Duel.RevealCards(g)
    if x:IsSigni() and x:GetLevel()==n then Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_KEY)
  e3:SetTiming(TIMING_ATTACK)
  e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) end
    Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
  end)
  e3:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,1)
    local x=g:GetFirst()
    if not x then return end
    Duel.RevealCards(g)
    if x:IsSigni() then Duel.PutOnField(x,tp,true) end
  end)
  c:RegisterEffect(e3)
end
