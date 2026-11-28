-- WXEX1-50 ドライ＝チョコキラー
-- 【自】：あなたのアタックフェイズ開始時、あなたの場にパワー20000以上の＜毒牙＞のシグニがある場合、カードを１枚引き、【エナチャージ１】をする。
-- 【起】《ターン１回》《黒》：対戦相手の手札を見て無色ではないレベル３以下のシグニ１枚を選び、対戦相手はそれを場に出す。それの【出】能力は発動しない。
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e1:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_DOKUGA) and x:GetPower()>=20000 end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then
      Duel.Draw(tp,1)
      Duel.EnaCharge(tp,1)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetEnaCost("{K}")
  e2:SetOperation(function(e,tp)
    local hg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    if hg:GetCount()==0 then return end
    Duel.ConfirmCards(tp,hg)
    local tc=Duel.SelectCards(tp,hg:Filter(function(x) return x:IsSigni() and x:GetColor()~=0 and x:GetLevel()<=3 end,nil),1,1):GetFirst()
    if tc then Duel.PutOnField(tc,1-tp,true) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp)
    if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then Duel.Draw(tp,1) else Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e9)
end
