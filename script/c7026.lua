-- WXK10-052 幻竜　ウァラク
-- 【自】：あなたの効果によってあなたのデッキから＜龍獣＞のシグニ１枚がトラッシュに置かれたとき、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－2000する。
-- 【自】：このシグニがアタックしたとき、０～５の数字１つを宣言する。あなたのデッキの上から宣言した数字に等しい枚数のカードをトラッシュに置く。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それをバニッシュする。あなたのデッキの上からカードを１０枚トラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) if rp~=tp or (r&REASON_EFFECT)==0 then return false end for x in eg:Iter() do if x:IsPreviousLocation(LOCATION_MDECK) and x:GetOwner()==tp and (function(x) return x:IsSigni() and x:IsClass(0,RACE_RYUJU) end)(x) then return true end end return false end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,-2000)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetOperation(function(e,tp,eg)
    local n=Duel.AnnounceNumber(tp,0,5)
    if n>0 then
      local g=Duel.GetDecktopGroup(tp,n)
      if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
    local g=Duel.GetDecktopGroup(tp,10)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e9)
end
