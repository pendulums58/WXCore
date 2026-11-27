-- WX20-067 文脈の攻防　モダーン
-- 【自】：アタックフェイズの間、カード１枚がいずれかのプレイヤーの手札に加えられたとき、対戦相手のシグニ１体を対象とし、《白》を支払い、アップ状態のこのシグニをダウンしてもよい。そうした場合、それを手札に戻す。
-- 【出】：あなたのトラッシュにカード名に《コンテンポラ》を含むカードがある場合、あなたのデッキから＜美巧＞のシグニ１枚を探してエナゾーンに置き、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_HAND)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetPhase()==PHASE_ATTACK and e:GetHandler():IsUp() end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and h:IsUp()) then return end
    if Duel.CanPayEna(tp,"{W}") and Duel.SelectYesNo(tp) then
      Duel.SendToTrash(Duel.SelectEnaCost(tp,"{W}"),REASON_COST)
      Duel.Down(h)
      Duel.SendToHand(tc)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    if not (Duel.GetMatchingGroup(function(x) return aux.NameHas(x,"コンテンポラ") end,tp,LOCATION_TRASH,0,nil):GetCount()>0) then return end
    local g=aux.Search(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end,1)
    if g:GetCount()>0 then Duel.SendToEna(g) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e2)
end
