-- WX21-006 遠かりし使　リワト＝フィーラ
-- 【自】：各アタックフェイズ開始時、対戦相手のシグニ１体を対象とし、あなたの場にそれぞれ共通する色を持たない＜天使＞のシグニが３体ある場合、それをバニッシュし、あなたのデッキの一番上のカードをエナゾーンに置き、カードを１枚引く。
-- 【起】《メインフェイズアイコン》《アタックフェイズアイコン》エクシード２：あなたのデッキから＜天使＞のシグニ１枚を探して場に出し、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_LRIG)
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetCondition(function(e,tp) return true end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    if not (function() local seen,cnt={},0 for x in Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,tp,LOCATION_SZONE,0,nil):Iter() do local c=x:GetColor() local ok=c~=0 for k in pairs(seen) do if k&c~=0 then ok=false end end if ok then seen[c]=true cnt=cnt+1 end end return cnt>=3 end)() then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
    Duel.EnaCharge(tp,1)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetExceedCost(2)
  e2:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e2:SetOperation(function(e,tp)
    local x=aux.Search(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e2)
end
