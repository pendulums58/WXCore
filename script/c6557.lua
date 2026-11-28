-- WXK05-013 聖マルディウス教会
-- 【常】：あなたのセンタールリグは以下の能力を得る。
-- 【起】《アタックフェイズアイコン》エクシード４（あなたのルリグの下からカードを合計４枚ルリグトラッシュに置く）：対戦相手のすべてのシグニをバニッシュする。
-- 【常】：あなたのターンの間、あなたのシグニのパワーを＋1000する。
local s,id=GetID()
function s.initial_effect(c)
  do
    local g=Effect.CreateEffect(c)
    g:SetType(EFFECT_TYPE_IGNITION)
    g:SetDescription(aux.Ability(id,1))
    g:SetRange(LOCATION_LRIG)
    g:SetExceedCost(4)
    g:SetTiming(TIMING_ATTACK)
    g:SetOperation(function(e,tp)
      local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
      if g:GetCount()>0 then Duel.Banish(g) end
    end)
    local e91=Effect.CreateEffect(c)
    e91:SetType(EFFECT_TYPE_FIELD)
    -- [の間] 【常】 센터 루리그가 얻는다
    e91:SetDescription(aux.Ability(id,0))
    e91:SetCode(EFFECT_GRANT)
    e91:SetRange(LOCATION_KEY)
    e91:SetTargetRange(LOCATION_LRIG,0)
    e91:SetLabelObject(g)
    c:RegisterEffect(e91)
  end
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EFFECT_UPDATE_POWER)
  e2:SetRange(LOCATION_KEY)
  e2:SetTargetRange(LOCATION_SZONE,0)
  e2:SetTarget(function(e,x) return x:IsSigni() end)
  e2:SetCondition(function(e) return Duel.GetTurnPlayer()==e:GetHandlerPlayer() end)
  e2:SetValue(1000)
  c:RegisterEffect(e2)
end
