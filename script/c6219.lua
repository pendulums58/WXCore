-- WXK01-036 コードアクセル　エフワン
-- 【ドライブ常】：【アサシン】
-- 【常】：あなたのターンの間、あなたの赤のシグニのパワーを＋2000する。
-- 【出】《赤》《赤》：あなたのデッキから《コードアクセル　エフワン》以外の＜乗機＞のシグニ１枚を探して場に出し、デッキをシャッフルする。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【ドライブ常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_ASSASSIN)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():IsDrive() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_UPDATE_POWER)
  e2:SetRange(LOCATION_SZONE)
  e2:SetTargetRange(LOCATION_SZONE,0)
  e2:SetTarget(function(e,x) return x:IsSigni() and x:IsColor(COLOR_RED) end)
  e2:SetCondition(function(e) return Duel.GetTurnPlayer()==e:GetHandlerPlayer() end)
  e2:SetValue(2000)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetEnaCost("{R}{R}")
  e3:SetOperation(function(e,tp,eg)
    -- 내지 않아도 된다(FAQ 3)
    local x=aux.Search(tp,function(y) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_JOUKI) end)(y) and not y:IsCardName(id) end,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e3)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e9:SetOperation(aux.BanishOp)
  c:RegisterEffect(e9)
end
