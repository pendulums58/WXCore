-- WDK16-09 マスト・ハイド
-- ターン終了時まで、対象の対戦相手のシグニ１体は「【常】：アタックできない。」を得る。
-- あなたの登録者数が７０万人を達成している場合、追加でターン終了時まで、対象の対戦相手のシグニ１体は「【常】：アタックできない。」を得る。
-- あなたの登録者数が１００万人を達成している場合、追加でターン終了時まで、対象の対戦相手のセンタールリグ１体は「【常】：アタックできない。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,Duel.GetSubscribers(tp)>=70 and 2 or 1,nil)
    if Duel.GetSubscribers(tp)>=100 then Duel.SelectTarget(tp,nil,tp,0,LOCATION_LRIG,1,1,nil) end
  end)
  -- 대상은 사용할 때의 登録者数로 정한다
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then aux.GrantKeyword(e,tc,EFFECT_CANNOT_ATTACK) end  -- [まで] ターン終了時まで
    end
  end)
  c:RegisterEffect(e1)
end
