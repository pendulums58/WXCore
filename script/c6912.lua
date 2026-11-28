-- WXK09-039 大海の蒼天　ポントス
-- 【自】：このシグニがアタックしたとき、《青》を支払ってもよい。そうした場合、カード名１つを宣言する。対戦相手の手札を見て宣言したカードを１枚選び、捨てさせる。
-- 【出】手札から＜天使＞のシグニを１枚エナゾーンに置く：対戦相手の手札を見る。
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②対戦相手は手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp,eg)
    if not (Duel.CanPayEna(tp,"{U}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{U}"),REASON_COST)
    local cid=Duel.AnnounceCard(tp)
    local h=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    Duel.ConfirmCards(tp,h)
    local g=h:Filter(function(x) return x:IsCardName(cid) end,nil)
    if g:GetCount()>0 then Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT+REASON_DISCARD) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_TENSHI) end,tp,LOCATION_HAND,0,nil)
    if chk==0 then return g:GetCount()>0 end
    Duel.SendToEna(Duel.SelectCards(tp,g,1,1))
  end)
  e2:SetOperation(function(e,tp,eg)
    Duel.ConfirmCards(tp,Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil))
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e9:SetOperation(function(e,tp,eg)
    if e:GetLabel()==0 then Duel.Draw(tp,1) else aux.Discard(1-tp,1) end
  end)
  c:RegisterEffect(e9)
end
