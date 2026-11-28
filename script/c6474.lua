-- WXK04-018 エルドラ　ＴＹＰＥ×Ⅰ／
-- 【デコレ】（あなたの＜調理＞のシグニ１体を対象とし、手札から＜調理＞のシグニ１枚をそれの【アクセ】にする。これはコストが《青×0》の【起】能力で、１ターンに一度しか使用できない）
-- （【アクセ】はシグニ１体に１枚までしか付けられない）
-- 【出】手札を１枚捨てる：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddDecore(c,aux.Ability(id,0))
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(aux.DiscardCost(1))
  e1:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e1)
end
