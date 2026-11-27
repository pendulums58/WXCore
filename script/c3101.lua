-- WX20-001 未来の記憶　リル
-- 【自】：あなたのターン開始時、《コインアイコン》《コインアイコン》を得る。
-- 【出】：あなたのトラッシュから＜武勇＞のシグニを３枚まで対象とし、それらを場に出す。それらの【出】能力は発動せず、ターン終了時、それらを場からトラッシュに置く。
-- 【起】《ターン２回》《コインアイコン》：あなたのデッキから＜武勇＞のシグニ１枚を探して場に出し、デッキをシャッフルする。
-- 【起】《アタックフェイズアイコン》《コインアイコン》《コインアイコン》《コインアイコン》《コインアイコン》：対戦相手のシグニ２体を対象とし、それらをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_UP)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e1:SetOperation(function(e,tp)
    Duel.AddCoin(tp,2)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_BUYU)) end,tp,LOCATION_TRASH,0,0,3,nil)
  end)
  e2:SetOperation(function(e,tp)
    local out=Group.CreateGroup()
    for x in Duel.GetTargets():Iter() do if x:IsRelateToEffect(e) and Duel.PutOnField(x,tp,true) then out:AddCard(x) end end
    if out:GetCount()==0 then return end
    local e9=Effect.CreateEffect(e:GetHandler())
    e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e9:SetCode(EVENT_TURN_END)
    e9:SetOperation(function() local g=out:Filter(function(x) return x:IsLocation(LOCATION_SZONE) end,nil) if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end end)
    e9:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e9,tp)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(2)
  e3:SetCoinCost(1)
  e3:SetOperation(function(e,tp)
    local x=aux.Search(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_BUYU)) end,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_IGNITION)
  e4:SetDescription(aux.Ability(id,3))
  e4:SetRange(LOCATION_LRIG)
  e4:SetCoinCost(4)
  e4:SetTiming(TIMING_ATTACK)
  e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,2,2,nil)
  end)
  e4:SetOperation(function(e,tp)
    for x in Duel.GetTargets():Iter() do if x:IsRelateToEffect(e) then Duel.Banish(x) end end
  end)
  c:RegisterEffect(e4)
end
