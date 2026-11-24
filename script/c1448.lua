-- WDK07-Y09 月鍵の巫女　タマヨリヒメ
-- 【出】：あなたのデッキからあなたのセンタールリグと同じレベルと共通する色を持つシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- 【起】このキーを場からルリグトラッシュに置く：あなたのデッキからあなたのセンタールリグと同じレベルと共通する色を持つシグニを２枚まで探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    s.search(tp,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_KEY)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) end
    Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
  end)
  e2:SetOperation(function(e,tp)
    s.search(tp,2)
  end)
  c:RegisterEffect(e2)
end
-- 무색끼리는 공통된 색이 없다(FAQ 1)
function s.search(tp,n)
  local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
  if not lc then return end
  local lv,col=lc:GetLevel(),lc:GetColor()
  aux.SearchToHand(tp,function(x) return x:IsSigni() and x:IsLevelBetween(lv,lv) and x:GetColor()&col~=0 end,n)
end
