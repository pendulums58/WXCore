-- WX08-046 幻蟲　タマムシ
-- 【出】：対戦相手のシグニ１体を対象とし、対戦相手のデッキの一番上のカードをそれの【チャーム】にしてもよい。
-- （【チャーム】は裏向きでシグニに付き、１体に１枚までしか付けられない）
-- ライフバースト：どちらか１つを選ぶ。
-- ①対戦相手は自分のシグニ１体につき自分のデッキの上からカード１枚を、それらの【チャーム】にする。②対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－5000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    local top=Duel.GetDecktopGroup(1-tp,1):GetFirst()
    if tc and tc:IsRelateToEffect(e) and top and not tc:GetCharm() and Duel.SelectYesNo(tp) then Duel.Charm(top,tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==1 then Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e2:SetOperation(function(e,tp)
    if e:GetLabel()==0 then
      for x in Duel.GetMatchingGroup(Card.IsSigni,1-tp,LOCATION_SZONE,0,nil):Iter() do
        local top=Duel.GetDecktopGroup(1-tp,1):GetFirst()
        if top and not x:GetCharm() then Duel.Charm(top,x) end
      end
      return
    end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-5000) end
  end)
  c:RegisterEffect(e2)
end
