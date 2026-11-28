-- WXK05-024 魔界の末娘　アナスタシア
-- 【常】：あなたの＜悪魔＞のシグニは場から手札に戻らない。
-- 【常】：このシグニが場を離れる場合、代わりにこのシグニをゲームから除外する。
-- 【起】《青》《無》：対戦相手のシグニ１体を対象とし、あなたの手札が０枚の場合、このシグニをトラッシュから場に出す。そうした場合、それをトラッシュに置く。
-- ライフバースト：どちらか１つを選ぶ。①対戦相手のシグニ１体を対象とし、あなたの手札が１枚以下の場合、それをバニッシュする。②カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_NO_BOUNCE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_AKUMA) end)(x) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_LEAVE_EXCLUDE)
  e2:SetRange(LOCATION_SZONE)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_TRASH)
  e3:SetEnaCost("{U}{C}")
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()==0 and h:IsLocation(LOCATION_TRASH) and Duel.PutOnField(h,tp) and tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e3)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e9:SetOperation(function(e,tp,eg)
    if e:GetLabel()==1 then Duel.Draw(tp,1) return end
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc and Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()<=1 then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e9)
end
