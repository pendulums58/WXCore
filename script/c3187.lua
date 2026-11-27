-- WX21-024 荒ぶる海洋　§ポセイドナ§
-- 【出】：あなたのトラッシュから共通する色を持たないレベル４以下の＜天使＞のシグニを２枚まで対象とし、それらをこのシグニの下に置く。
-- 【常】：このシグニはこのカードの下にある《荒ぶる海洋　§ポセイドナ§》以外の＜天使＞のシグニの【常】と【自】と【起】の能力と、限定条件を得る。
-- ライフバースト：あなたのデッキから＜天使＞のシグニ１枚を探して公開し手札に加える。その後、デッキをシャッフルし、対戦相手のセンタールリグかシグニ１体を対象とし、それをダウンする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end)(x) and x:GetLevel()<=4 end,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 and h:IsLocation(LOCATION_SZONE) then Duel.PutUnder(h,g) end
  end)
  c:RegisterEffect(e1)
  -- 【常】 「下にある＜天使＞の能力と限定条件を得る」는 아직(근사 없음)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,1)
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() or x:IsType(TYPE_LRIG) end,tp,0,LOCATION_SZONE+LOCATION_LRIG,1,1,nil):GetFirst()
    if tc then Duel.Down(tc) end
  end)
  c:RegisterEffect(e2)
end
