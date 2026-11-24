-- WD11-009 幻蟲　クロハ
-- 【常】：あなたの場にレゾナがあるかぎり、このシグニの基本パワーは15000になる。
-- 【出】《黒》：あなたのトラッシュからレベル２以下の黒のシグニ１枚を対象とし、それを場に出す。
-- ライフバースト：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－10000する。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,15000,function(e)
    return Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_RESONA) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0
  end)
  -- 코스트로 트래시에 간 카드도 대상이 된다(FAQ 1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{B}")
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,s.filter,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(s.opptg)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-10000) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e3)
end
function s.filter(c) return c:IsSigni() and c:IsColor(COLOR_BLACK) and c:GetLevel()<=2 end
function s.opptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
end
