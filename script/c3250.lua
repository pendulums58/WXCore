-- WX22-028 羅原　Ｏｇ
-- 【自】：このシグニがアタックしたとき、手札から＜原子＞のシグニを２枚捨ててもよい。そうした場合、以下の２つから１つを選ぶ。
-- ①カードを３枚引く。
-- ②対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：あなたのデッキから＜原子＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end,tp,LOCATION_HAND,0,nil)
    if g:GetCount()<2 or not Duel.SelectYesNo(tp) then return end
    Duel.SendToTrash(Duel.SelectCards(tp,g,2,2),REASON_EFFECT+REASON_DISCARD)
    if Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1]==0 then Duel.Draw(tp,3) return end
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end,1)
  end)
  c:RegisterEffect(e2)
end
