-- WXK10-020 双獄の閻魔　ウリス＆カーニバル
-- 【出】：あなたのトラッシュから黒のカード１枚を対象とし、それを手札に加える。
-- 【起】《ターン１回》《黒》：あなたのデッキの上からカードを３枚トラッシュに置く。その後、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーをこの方法でトラッシュに置かれたシグニのレベルの合計１につき－1000する。
-- 【起】このキーを場からルリグトラッシュに置く：あなたのセンタールリグ１体を対象とし、ターン終了時まで、それは「【自】：このルリグがアタックしたとき、あなたのシグニ１体を対象とし、それをライフクロスに加える。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsColor(COLOR_BLACK) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToHand(tc)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_KEY)
  e2:SetCountLimit(1)
  e2:SetEnaCost("{B}")
  e2:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    local n=0
    for x in g:Iter() do if x:IsSigni() then n=n+x:GetLevel() end end
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc and n>0 then aux.AddPower(e,tc,-1000*n) end
  end)
  c:RegisterEffect(e2)
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
    Duel.SelectTarget(tp,nil,tp,LOCATION_LRIG,0,1,1,nil)
  end)
  e3:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local g=Effect.CreateEffect(e:GetHandler())
      g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
      g:SetDescription(aux.Stringid(id,0))
      g:SetCode(EVENT_ATTACK)
      g:SetOperation(function(e,tp) local x=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil):GetFirst() if x then Duel.SendToLife(x) end end)
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_GRANT)
      e1:SetLabelObject(g)
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:GrantEffect(e1)
    end
  end)
  c:RegisterEffect(e3)
end
