-- PR-288 小砲　アルマイル（カードゲーマーvol.28 付録）
-- 【常】：あなたのセンタールリグがレベル２以上であるかぎり、このシグニの基本パワーは1000になる。
-- 【常】：このシグニが中央のシグニゾーンにあるかぎり、「【自】：このシグニがアタックしたとき、対戦相手のパワー2000以下のシグニ１体を対象とし、あなたのセンタールリグのレベルが対戦相手のセンタールリグと同じ場合、それをバニッシュする。」を得る。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  aux.BasePower(c,1000,function(e) local tp=e:GetHandlerPlayer() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:GetLevel()>=2 end)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Ability(id,1))
  g:SetCode(EVENT_ATTACK)
  g:SetOperation(function(e,tp)
    local a,b=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst(),Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst()
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=2000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc and a and b and a:GetLevel()==b:GetLevel() then Duel.Banish(tc) end
  end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】 가운데 존에 있는 동안
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x==e:GetHandler() and x:IsInZone("signi_center") end)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
end
