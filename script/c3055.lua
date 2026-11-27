-- WX19-028 幻獣神　クジャク
-- 【自】：あなたのシグニが【ランサー】によって対戦相手のライフクロスをクラッシュしたとき、カードを１枚引く。
-- 【自】：あなたのターン終了時、対戦相手のライフクロスが０枚の場合、あなたのデッキの上からカードを２枚エナゾーンに置く。
-- 【出】：あなたのルリグデッキから＜空獣＞か＜地獣＞のレゾナ１枚を出現条件を無視して場に出す。
-- ライフバースト：対戦相手のパワー8000以上のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_CRUSHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) return ep~=tp and r&REASON_LANCER~=0 end)
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_TURN_END)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp and Duel.GetMatchingGroup(nil,tp,0,LOCATION_LIFE,nil):GetCount()==0 end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,2)
    if g:GetCount()>0 then Duel.SendToEna(g) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetOperation(function(e,tp)
    local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(c) return c:IsType(TYPE_RESONA) and (c:IsClass(0,RACE_KUJU) or c:IsClass(0,RACE_CHIJU)) end,tp,LOCATION_LDECK,0,nil),0,1):GetFirst()
    if x then Duel.PutOnField(x,tp,false) end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return true end Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=8000 end,tp,0,LOCATION_SZONE,1,1,nil) end)
  e4:SetOperation(aux.BanishOp)
  c:RegisterEffect(e4)
end
