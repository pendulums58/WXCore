-- WX14-024 真実の聖盾　*マウス*
-- 【常】：あなたの場に緑の＜美巧＞のシグニが２体以上あるかぎり、このシグニの基本パワーは12000になる。
-- 【自】：あなたの＜美巧＞のシグニ１体が手札以外の領域から場に出たとき、対戦相手のシグニ１体を対象とし、《白》を支払ってもよい。そうした場合、それを手札に戻す。（このシグニが場に出たときも発動する）
-- ライフバースト：あなたのデッキから＜美巧＞のシグニ１枚を探して公開し手札に加えるかエナゾーンに置くか場に出し、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,12000,function(e) return Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end)(x) and x:IsColor(COLOR_GREEN) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>=2 end)
  -- 자신도(괄호)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()==tp and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end)(x) and not x:IsPreviousLocation(LOCATION_HAND) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    if not (Duel.CanPayEna(tp,"{W}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{W}"),REASON_COST)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    local x=aux.Search(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end,1):GetFirst()
    if x then
      Duel.RevealCards(x)
      local m=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
      if m==0 then Duel.SendToHand(x) elseif m==1 then Duel.SendToEna(x) else Duel.PutOnField(x,tp) end
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e2)
end
