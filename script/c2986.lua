-- WX18-032 羅星姫　≡コスモウス≡
-- 【自】《ターン２回》：このシグニが対戦相手のライフクロス１枚をクラッシュしたとき、対戦相手のライフクロスがあなたより多い場合、このシグニをアップする。
-- 【出】：対戦相手の手札が６枚以上ある場合、対戦相手は手札が３枚になるようにカードを捨てる。
-- ライフバースト：どちらか１つを選ぶ。①対戦相手の手札があなたより多い場合、カードを２枚引く。②対戦相手のシグニ１体を対象とし、対戦相手のライフクロスの枚数があなたより多い場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_CRUSHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(2)
  e1:SetCondition(function(e,tp,eg,ep) return ep~=tp and Duel.GetCrusher()==e:GetHandler() end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if Duel.GetMatchingGroup(nil,tp,0,LOCATION_LIFE,nil):GetCount()>Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount() and h:IsLocation(LOCATION_SZONE) then Duel.Up(h) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local n=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil):GetCount()
    if n>=6 then aux.Discard(1-tp,n-3) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e3:SetOperation(function(e,tp)
    if e:GetLabel()==0 then
      if Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil):GetCount()>Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount() then Duel.Draw(tp,2) end
      return
    end
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc and Duel.GetMatchingGroup(nil,tp,0,LOCATION_LIFE,nil):GetCount()>Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount() then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e3)
end
