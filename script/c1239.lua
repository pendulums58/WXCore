-- WD13-015 巨弓　カタパル
-- 【出】：あなたのデッキの一番上を見る。それがレベル２以下のシグニであなたの場に他のシグニがない場合、それを場に出してもよい。
-- ライフバースト：あなたのデッキからレベル４の白のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,1)
    local tc=g:GetFirst()
    if not tc then return end
    Duel.ConfirmCards(tp,g)
    if not (tc:IsSigni() and tc:GetLevel()<=2) then return end
    if Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,e:GetHandler()):GetCount()>0 then return end
    if Duel.SelectYesNo(tp) then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_WHITE) and x:GetLevel()==4 end,1)
  end)
  c:RegisterEffect(e2)
end
