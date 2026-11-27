-- WX22-027 井伊の赤鬼　ナオマサ
-- 【自】：このカードがコストか効果によってシグニの下からトラッシュに置かれたとき、シグニ１体を対象とし、それをアップするかダウンする。
-- 【出】：対戦相手のパワー12000以下のシグニ１体を対象とし、あなたのデッキの一番上を公開する。それが《ライズアイコン》を持つシグニの場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) return r&(REASON_COST+REASON_EFFECT)~=0 and e:GetHandler():GetPreviousLocation()==0 end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if tc:IsUp() then Duel.Down(tc) else Duel.Up(tc) end end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=12000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local x=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not x then return end
    Duel.RevealCards(Group.CreateGroup(x))
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and x:IsSigni() and x:HasRiseIcon() then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
end
