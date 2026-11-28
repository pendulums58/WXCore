-- WXK05-026 コードオーダー　ＢＣＰＩＣ
-- 【出】：あなたの＜調理＞のシグニ１体を対象とし、あなたの手札から＜調理＞のシグニ１枚をそれの【アクセ】にする。
-- 【起】《ターン１回》あなたの【アクセ】１枚をトラッシュに置く：カードを１枚引く。
-- 【起】《ターン１回》《青》あなたの【アクセ】１枚をトラッシュに置く：ターン終了時まで、このシグニは【アサシン】を得る。
-- ライフバースト：どちらか１つを選ぶ。①対戦相手のシグニ１体を対象とし、それをダウンし凍結する。②カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_CHOURI) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    local h=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_CHOURI) end,tp,LOCATION_HAND,0,nil)
    if tc and tc:IsRelateToEffect(e) and h:GetCount()>0 then Duel.Acce(Duel.SelectCards(tp,h,1,1):GetFirst(),tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local a=Duel.GetMatchingGroup(nil,tp,LOCATION_ACCE,0,nil)
    if chk==0 then return a:GetCount()>0 end
    Duel.SendToTrash(Duel.SelectCards(tp,a,1,1),REASON_COST)
  end)
  e2:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_SZONE)
  e3:SetCountLimit(1)
  e3:SetEnaCost("{U}")
  e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local a=Duel.GetMatchingGroup(nil,tp,LOCATION_ACCE,0,nil)
    if chk==0 then return a:GetCount()>0 end
    Duel.SendToTrash(Duel.SelectCards(tp,a,1,1),REASON_COST)
  end)
  e3:SetOperation(function(e,tp,eg)
    aux.GrantKeyword(e,e:GetHandler(),EFFECT_ASSASSIN)
  end)
  c:RegisterEffect(e3)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e9:SetOperation(function(e,tp,eg)
    if e:GetLabel()==1 then Duel.Draw(tp,1) return end
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Down(tc) Duel.Freeze(tc) end
  end)
  c:RegisterEffect(e9)
end
