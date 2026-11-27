-- WX06-018 弩炎　フレイスロ大佐
-- 【自】：このシグニがアタックしたとき、あなたのデッキの上からカードを３枚トラッシュに置く。その後、この方法でトラッシュに置かれた＜ウェポン＞のシグニの枚数が１枚の場合、対戦相手のパワー3000以下のシグニ１体を対象とし、それをバニッシュする。２枚の場合、対戦相手のパワー8000以下のシグニ１体を対象とし、それをバニッシュする。３枚の場合、対戦相手のパワー15000以下のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：パワーが「あなたのトラッシュにある＜ウェポン＞のシグニの枚数×3000」以下の対戦相手のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  -- 넘긴 뒤에 대상을 고른다(FAQ 1)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    local n=g:Filter(function(x) return x:IsLocation(LOCATION_TRASH) and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_WEAPON)) end)(x) end,nil):GetCount()
    local lim=({3000,8000,15000})[n]
    if not lim then return end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=lim end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  -- 발동했을 때의 트래시 장수(FAQ 3)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local n=3000*Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_WEAPON)) end,tp,LOCATION_TRASH,0,nil):GetCount()
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=n end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
end
