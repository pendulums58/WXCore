-- WX16-Re19 白羅星　ネプチューン
-- 【出現条件】《メインフェイズアイコン》レゾナではないレベル２以下の＜宇宙＞のシグニ２体をあなたの場からトラッシュに置く
-- 【出】：あなたのデッキからレベル１のシグニ１枚を探して場に出し、デッキをシャッフルする。
-- 【出】：次の対戦相手のメインフェイズの間、対戦相手のセンタールリグのリミットは１減る。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,2,function(x) return aux.NonResonaClass(RACE_UCHU)(x) and x:GetLevel()<=2 end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local x=aux.Search(tp,function(c) return c:IsSigni() and c:GetLevel()==1 end,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    -- [の間] 「次の対戦相手のメインフェイズの間」
    local now=Duel.GetTurnCount()
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_LIMIT)
    e1:SetTargetRange(0,LOCATION_LRIG)
    e1:SetCondition(function() return Duel.GetTurnCount()==now+1 and Duel.GetPhase()==PHASE_MAIN end)
    e1:SetValue(-1)
    e1:SetReset(RESET_PHASE+PHASE_END,2)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e2)
end
