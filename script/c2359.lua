-- WX09-035 ドライ＝ソマナ
-- 【出】《黒》：対戦相手のシグニ１体を対象とし、あなたの場に＜毒牙＞のシグニが３体ある場合、ターン終了時まで、それのパワーを－7000する。
-- （パワーが０以下のシグニはルールによってバニッシュされる）
-- ライフバースト：あなたのデッキから＜毒牙＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{B}")
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_DOKUGA)) end,tp,LOCATION_SZONE,0,nil):GetCount()>=3 then aux.AddPower(e,tc,-7000) end end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_DOKUGA)) end,1)
  end)
  c:RegisterEffect(e2)
end
