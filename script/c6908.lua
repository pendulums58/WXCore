-- WXK09-035 白雪の童話　ユキジロヒメ
-- 【自】：このカードがデッキからトラッシュに置かれたとき、対戦相手のシグニ１体を対象とし、あなたのターンの場合、《黒》を支払ってもよい。そうした場合、ターン終了時まで、それのパワーを対戦相手のセンタールリグのレベル１につき－2000する。
-- 【出】：あなたのデッキの上からカードを５枚トラッシュに置く。その後、この方法でカードが５枚トラッシュに置かれた場合、あなたのトラッシュから黒のシグニ５枚を対象とし、それらをデッキに加えてシャッフルする。
-- ライフバースト：あなたのトラッシュからシグニ１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  -- 「レベル１につき－…」(근사: 레벨당 －2000)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetCondition(function(e,tp) return e:GetHandler():IsPreviousLocation(LOCATION_MDECK) and Duel.GetTurnPlayer()==tp end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    local lc=Duel.GetMatchingGroup(nil,1-tp,LOCATION_LRIG,0,nil):GetFirst()
    if not (Duel.CanPayEna(tp,"{B}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{B}"),REASON_COST)
    aux.AddPower(e,tc,-2000*(lc and lc:GetLevel() or 0))
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,5)
    local n=g:GetCount()>0 and Duel.SendToTrash(g,REASON_EFFECT) or 0
    if n<5 then return end
    local b=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,tp,LOCATION_TRASH,0,5,5,nil)
    if b:GetCount()>0 then Duel.SendToDeckShuffle(b) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToHand(tc)
    end
  end)
  c:RegisterEffect(e9)
end
