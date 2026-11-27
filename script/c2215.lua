-- WX07-046 破戒の左像　アギョウ
-- 《クロスアイコン》《破滅の右像》の左
-- 【クロス出】：あなたのデッキの一番上のカードをこのシグニの【チャーム】にする。その後、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－5000する。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,2200,CROSS_LEFT)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCondition(function(e) return e:GetHandler():IsCross() end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    local top=Duel.GetDecktopGroup(tp,1):GetFirst()
    if top and h:IsLocation(LOCATION_SZONE) and not h:GetCharm() then Duel.Charm(top,h) end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-5000) end
  end)
  c:RegisterEffect(e1)
end
