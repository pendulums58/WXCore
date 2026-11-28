-- PR-442 ビッカメ娘　（水戸たんウインク仕様）
-- 【常】：このシグニのパワーはあなたのデッキの枚数１０枚につき＋4000される。
-- 【自】：このシグニがアタックしたとき、あなたのデッキの上からカードを１０枚トラッシュに置く。この方法でカードを１０枚トラッシュに置いた場合、カードを２枚引く。
-- 【自】：このシグニが場からトラッシュに置かれたとき、あなたは手札を１枚捨てる。
-- ライフバースト：あなたのデッキの枚数１０枚につきカードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetValue(function(e) return 4000*(Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_MDECK,0,nil):GetCount()//10) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,10)
    if g:GetCount()>0 and Duel.SendToTrash(g,REASON_EFFECT)==10 then Duel.Draw(tp,2) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_TO_TRASH)
  e3:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_SZONE) end)
  e3:SetOperation(function(e,tp)
    aux.Discard(tp,1)
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetOperation(function(e,tp)
    local n=Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil):GetCount()//10
    if n>0 then Duel.Draw(tp,n) end
  end)
  c:RegisterEffect(e4)
end
