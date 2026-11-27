-- WX14-CB02 暁月
-- 【常】：あなたの《燦》はバニッシュされない。
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、あなたのアップ状態の＜アーム＞のシグニ１体をダウンしてもよい。そうした場合、それを手札に戻す。
-- ライフバースト：あなたのデッキから《暁月》１枚と《燦》１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_CANNOT_BANISH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x:IsCardName(2739) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_ARM)) end)(x) and x:IsUp() end,tp,LOCATION_SZONE,0,nil)
    if g:GetCount()==0 or not Duel.SelectYesNo(tp) then return end
    Duel.Down(Duel.SelectCards(tp,g,1,1))
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    for _,cid in ipairs({2740,2739}) do aux.SearchToHand(tp,function(x) return x:IsCardName(cid) end,1) end
  end)
  c:RegisterEffect(e3)
end
