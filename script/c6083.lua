-- WXEX1-49 魔鳩の飼育　ゴージアウト
-- 【自】：このシグニがアタックしたとき、あなたのトラッシュからパワー7000以下の＜悪魔＞のシグニ１枚を対象とし、それを手札に加えるか場に出す。
-- 【自】《ターン１回》：効果１つによってデッキからカードが３枚以上トラッシュに置かれたとき、対戦相手のシグニ１体を対象とし、【エナチャージ１】をし、ターン終了時まで、それのパワーを－8000する。
-- ライフバースト：各プレイヤーは自分のデッキの上からカードを５枚トラッシュに置く。その後、あなたのトラッシュからシグニ１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_AKUMA) and x:GetPower()<=7000 end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then Duel.SendToHand(tc) else Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_TO_TRASH)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCondition(function(e,tp,eg,ep,ev,re,r)
    return r&REASON_EFFECT~=0 and eg:Filter(function(x) return x:IsPreviousLocation(LOCATION_MDECK) end,nil):GetCount()>=3
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    Duel.EnaCharge(tp,1)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-8000) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp)
    local g1=Duel.GetDecktopGroup(tp,5)
    local g2=Duel.GetDecktopGroup(1-tp,5)
    if g1:GetCount()>0 then Duel.SendToTrash(g1,REASON_EFFECT) end
    if g2:GetCount()>0 then Duel.SendToTrash(g2,REASON_EFFECT) end
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if tc then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e9)
end
