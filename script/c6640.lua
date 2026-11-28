-- WXK06-025 ＧＦ　コンパクト
-- 【常】：対戦相手のレベル１以下のシグニの【出】能力は発動しない。
-- 【自】：このシグニがアタックしたとき、正面のシグニ１体を対象とし、それをトラッシュに置いてもよい。そうした場合、対戦相手は手札からシグニ１枚を場に出してもよい。
-- ライフバースト：カードを１枚引く。あなたのライフクロスが４枚以下の場合、追加で【エナチャージ１】をする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_DISABLE_ABILITY)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(0,LOCATION_SZONE)
  e1:SetTarget(function(e,x) return x:IsSigni() and x:GetLevel()<=1 end)
  e1:SetValue(ABILITY_ON_PLAY)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local f=e:GetHandler():GetFrontCard()
    Duel.SelectTarget(tp,function(x) return x==f end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and Duel.SelectYesNo(tp)) or Duel.SendToTrash(tc,REASON_EFFECT)==0 then return end
    local h=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_SIGNI) end,1-tp,LOCATION_HAND,0,nil)
    if h:GetCount()>0 and Duel.SelectYesNo(1-tp) then Duel.PutOnField(Duel.SelectCards(1-tp,h,1,1):GetFirst(),1-tp) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()<=4 then Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e9)
end
