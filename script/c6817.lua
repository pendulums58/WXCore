-- WXK08-030 弩書　ゼロイゴナ
-- 【ライズ】あなたの＜ウェポン＞のシグニ１体の上に置く
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、このシグニの下にカードが２枚以上ある場合、それをバニッシュする。５枚以上ある場合、代わりにそれをトラッシュに置く。
-- 【出】：あなたのすべての＜ウェポン＞のシグニの下に、それぞれあなたのトラッシュからシグニを１枚ずつ選び置く。
-- ライフバースト：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－13000する。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddRise(c,function(x) return x:IsSigni() and x:IsClass(0,RACE_WEAPON) end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local n=e:GetHandler():GetUnderGroup():GetCount()
      if n>=5 then Duel.SendToTrash(tc,REASON_EFFECT) elseif n>=2 then Duel.Banish(tc) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp,eg)
    for x in Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_WEAPON) end,tp,LOCATION_SZONE,0,nil):Iter() do
      local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_TRASH,0,nil)
      if g:GetCount()==0 then break end
      Duel.PutUnder(x,Duel.SelectCards(tp,g,1,1))
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
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,-13000)
    end
  end)
  c:RegisterEffect(e9)
end
