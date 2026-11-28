-- WXK10-074 コードイート　ワラビモチ
-- 【出】《青》：あなたの＜調理＞のシグニ１体を対象とし、あなたのデッキから＜調理＞のシグニ１枚を探してそれの【アクセ】にし、デッキをシャッフルする。
-- 【常】：これにアクセされているシグニは「【自】：このシグニがアタックしたとき、対戦相手の手札を見て、このシグニよりパワーの低いシグニ１枚を選び、捨てさせる。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{U}")
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_CHOURI) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local x=aux.Search(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_CHOURI) end,1):GetFirst()
      if x then Duel.Acce(x,tc) end
      aux.ShuffleDeck(tp)
    end
  end)
  c:RegisterEffect(e1)
  -- 【常】「これにアクセされているシグニは…を得る」는 아직
end
