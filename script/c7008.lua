-- WXK10-034 コードＶＬ　戌亥とこ
-- 【自】：このシグニがアタックしたとき、あなたの場に《コードＶＬ　リゼ・ヘルエスタ》と《コードＶＬ　アンジュ・カトリーナ》がある場合、カードを１枚引く。
-- 【出】手札を１枚捨てる：あなたのデッキからレベル２の＜電機＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp,eg)
    if Duel.GetMatchingGroup(function(x) return x:IsCardName(7009) end,tp,LOCATION_SZONE,0,nil):GetCount()>0 and Duel.GetMatchingGroup(function(x) return x:IsCardName(7010) end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetCost(aux.DiscardCost(1))
  e2:SetOperation(function(e,tp,eg)
    aux.SearchToHand(tp,function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end)(x) and x:GetLevel()==2 end,1)
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e9)
end
