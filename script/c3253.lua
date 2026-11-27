-- WX22-031 彷徨変異の中悪　シユラギ
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、あなたのトラッシュにカード名に《サユラギ》を含むカードがある場合、ターン終了時まで、それのパワーをすべてのプレイヤーのトラッシュにあるカード４枚につき－1000する。
-- 【出】：各プレイヤーは自分のデッキの上からカードを３枚トラッシュに置く。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) or not (Duel.GetMatchingGroup(function(x) return aux.NameHas(x,"サユラギ") end,tp,LOCATION_TRASH,0,nil):GetCount()>0) then return end
    local n=Duel.GetMatchingGroup(nil,tp,LOCATION_TRASH,LOCATION_TRASH,nil):GetCount()
    aux.AddPower(e,tc,-1000*math.floor(n/4))  -- [まで]
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    for p=0,1 do local g=Duel.GetDecktopGroup(p,3) if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e3)
end
