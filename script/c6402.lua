-- WXK03-028 超罠　モリアーティ
-- 【常】：レベルが奇数の対戦相手のシグニは「【常】：アタックできない。」を得る。
-- 【自】：レベルが偶数のあなたのシグニ１体が場に出たとき、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－3000する。
-- 【出】《黒》：あなたのデッキの一番上のカードをトラッシュに置く。それがレベルが偶数のシグニの場合、それをトラッシュから場に出す。
-- ライフバースト：レベルが奇数の対戦相手のすべてのシグニをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE)
  g:SetCode(EFFECT_CANNOT_ATTACK)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(0,LOCATION_SZONE)
  e1:SetTarget(function(e,x) return x:IsSigni() and x:GetLevel()%2==1 end)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  -- 자신이 나왔을 때도(FAQ 2)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()==tp and x:IsSigni() and x:GetLevel()%2==0 end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,-3000)
    end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetEnaCost("{B}")
  e3:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,1)
    local x=g:GetFirst()
    if not x then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    if x:IsLocation(LOCATION_TRASH) and x:IsSigni() and x:GetLevel()%2==0 then Duel.PutOnField(x,tp) end
  end)
  c:RegisterEffect(e3)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetLevel()%2==1 end,tp,0,LOCATION_SZONE,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e9)
end
