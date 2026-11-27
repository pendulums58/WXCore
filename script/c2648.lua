-- WX13-077 幻獣　ユリカモメ
-- 【自】：このシグニがバニッシュされたとき、《緑》を支払ってもよい。そうした場合、あなたのデッキからレベル４の＜空獣＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- 【出】：あなたのトラッシュに《幻獣　メジロ》と《幻獣　ウグイス》がある場合、あなたのデッキの一番上のカードをエナゾーンに置く。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetOperation(function(e,tp)
    if not (Duel.CanPayEna(tp,"{G}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{G}"),REASON_COST)
    aux.SearchToHand(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KUJU)) end)(x) and x:GetLevel()==4 end,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(function(x) return x:IsCardName(2654) end,tp,LOCATION_TRASH,0,nil):GetCount()>0 and Duel.GetMatchingGroup(function(x) return x:IsCardName(2650) end,tp,LOCATION_TRASH,0,nil):GetCount()>0 then Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e3)
end
