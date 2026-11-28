-- WXK10-037 古代乗機　ギュウシャ
-- 【常】：あなたのターンの間、あなたの赤のシグニのパワーを＋2000する。
-- 【起】《ターン１回》アップ状態のセンタールリグ１体をダウンする：あなたのデッキからあなたのセンタールリグのレベル以下の赤のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x:IsColor(COLOR_RED) end)
  e1:SetCondition(function(e) return Duel.GetTurnPlayer()==e:GetHandlerPlayer() end)
  e1:SetValue(2000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if chk==0 then return lc and not lc:IsDown() end
    Duel.Down(lc,REASON_COST)
  end)
  e2:SetOperation(function(e,tp,eg)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    local lv=lc and lc:GetLevel() or 0
    aux.SearchToHand(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_RED) and x:GetLevel()<=lv end,1)
  end)
  c:RegisterEffect(e2)
end
