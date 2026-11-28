-- WXK03-027 忍の御頭　ハンゾウ
-- 【自】《ターン１回》：対戦相手のシグニ１体がバニッシュされたとき、あなたのデッキの上からカードを３枚トラッシュに置く。
-- 【自】：効果１つによってあなたのデッキからカードが３枚以上トラッシュに置かれたとき、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－5000する。
-- ライフバースト：あなたのデッキの上からカードを３枚トラッシュに置く。その後、あなたのトラッシュから＜武勇＞のシグニ１枚を対象とし、それを手札に加えるか場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep) return ep~=tp end)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  -- 효과 하나로 3장 이상(근사: 한 번의 이동 묶음)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_TO_TRASH)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg) local n=0 for x in eg:Iter() do if x:GetOwner()==tp and x:IsPreviousLocation(LOCATION_MDECK) then n=n+1 end end return n>=3 end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,-5000)
    end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_BUYU) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if tc and not (Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==1 and Duel.PutOnField(tc,tp)) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e9)
end
