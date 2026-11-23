-- WDK08-L09 ＡＶＡＬ科学財団 (キー)
-- 【常】：あなたのターンの間、あなたの赤のシグニのパワーを＋2000する。
-- 【出】：あなたのセンタールリグが＜ＬｏＶ＞の場合、あなたのデッキから＜紅蓮＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- 【起】このキーを場からルリグトラッシュに置く：あなたのトラッシュから赤のシグニを２枚まで対象とし、それらを手札に加える。
local s,id=GetID()
s.guren=aux.ClassFilter(0,RACE_GUREN)  -- ＜紅蓮＞のシグニ
function s.red(c) return c:IsSigni() and c:IsColor(COLOR_RED) end
function s.initial_effect(c)
  -- [の間] 【常】 내 턴 동안, 내 빨간 시그니
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_KEY)
  e1:SetTargetRange(LOCATION_SIGNI,0)
  e1:SetTarget(function(e,x) return s.red(x) end)
  e1:SetValue(2000)
  e1:SetCondition(function(e) return Duel.GetTurnPlayer()==e:GetHandlerPlayer() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local center=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if center and center:IsLrigType(LRIG_LOV) then aux.SearchToHand(tp,s.guren,1) end
  end)
  c:RegisterEffect(e2)
  -- 「２枚まで」: 0~2장(FAQ 1)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_KEY)
  e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) end
    Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
  end)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,s.red,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e3:SetOperation(function(e,tp)
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
    end
  end)
  c:RegisterEffect(e3)
end
