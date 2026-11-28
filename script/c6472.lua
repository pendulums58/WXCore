-- WXK04-016 エルドラ　ＴＹＰＥ×Ⅲ／
-- 【デコレ】（あなたの＜調理＞のシグニ１体を対象とし、手札から＜調理＞のシグニ１枚をそれの【アクセ】にする。これはコストが《青×0》の【起】能力で、１ターンに一度しか使用できない）
-- （【アクセ】はシグニ１体に１枚までしか付けられない）
local s,id=GetID()
function s.initial_effect(c)
  aux.AddDecore(c,aux.Ability(id,0))
end
