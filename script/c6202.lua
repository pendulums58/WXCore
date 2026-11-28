-- WXK01-010 レイラ＝アクセル
-- 【ライド】（ターン終了時まで、このルリグは対象のあなたの＜乗機＞のシグニ１体に乗る。これはコストが《赤×0》の【起】能力で、１ターンに一度、このルリグがドライブ状態でない場合に使用できる）
-- （ルリグがシグニに乗っているかぎり、それらはドライブ状態である。ドライブ状態のルリグはアタックできない）
-- 【出】手札を１枚捨てる：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddRide(c,aux.Ability(id,0))
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
