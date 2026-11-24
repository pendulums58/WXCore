-- WDK07-E04 エルドラ　ＴＹＰＥ×Ⅰ
-- 【デコレ】（あなたの＜調理＞のシグニ１体を対象とし、手札から＜調理＞のシグニ１枚をそれの【アクセ】にする。これはコストが《青×0》の【起】能力で、１ターンに一度しか使用できない）
-- （【アクセ】はシグニ１体に１枚までしか付けられない）
-- 【出】手札を１枚捨てる：《コインアイコン》を得る。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddDecore(c,aux.Ability(id,0))
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetCost(aux.DiscardCost(1))
  e2:SetOperation(function(e,tp)
    Duel.AddCoin(tp,1)
  end)
  c:RegisterEffect(e2)
end
