-- WXK10-066 コードアンチ　ネフティス
-- 【出】：あなたのデッキから＜古代兵器＞のシグニを１枚まで探してトラッシュに置き、デッキをシャッフルする。
-- 【起】《ターン１回》手札から＜古代兵器＞のシグニを１枚捨てる：対戦相手のパワー8000以下のシグニ１体を対象とし、あなたのトラッシュからレベルの合計が５になるように＜古代兵器＞のシグニ２枚を好きな順番でデッキの一番下に置く。そうした場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    local x=aux.Search(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_KODAIHEIKI) end,1):GetFirst()
    if x then Duel.SendToTrash(x,REASON_EFFECT) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCost(aux.DiscardCost(1,function(x) return x:IsSigni() and x:IsClass(0,RACE_KODAIHEIKI) end))
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=8000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_KODAIHEIKI) end,tp,LOCATION_TRASH,0,nil)
      Duel.SetSelectCheck(function(sg) local n=0 for x in sg:Iter() do n=n+x:GetLevel() end return sg:GetCount()==0 or n==5 end)
      local sg=g:GetCount()>=2 and Duel.SelectCards(tp,g,0,2) or Group.CreateGroup()
      if sg:GetCount()==2 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,sg),false) Duel.Banish(tc) end
    end
  end)
  c:RegisterEffect(e2)
end
