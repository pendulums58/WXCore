-- WDK15-014 轟書　デマギア
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、このシグニの下にカードがある場合、ターン終了時まで、それのパワーを－7000する。
-- 【出】《黒》：あなたのデッキの一番上のカードをこのシグニの下に置く。
-- （シグニの下に置かれるカードは表向きである）
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
  -- 조건은 처리할 때 본다
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if e:GetHandler():GetUnderGroup():GetCount()>0 then aux.AddPower(e,tc,-7000) end end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{B}")
  e2:SetOperation(function(e,tp)
    local h,top=e:GetHandler(),Duel.GetDecktopGroup(tp,1)
    if h:IsLocation(LOCATION_SZONE) and top:GetCount()>0 then Duel.PutUnder(h,top) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e3)
end
