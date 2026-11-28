-- WDK12-017 羅菌 センイ
-- 【出】：あなたのトラッシュから対象の＜微菌＞のシグニ１枚を対象のあなたの他のシグニ１体の【チャーム】にする。
-- （【チャーム】は裏向きでシグニに付き、１体に１枚までしか付けられない）
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
s.germ=aux.ClassFilter(0,RACE_BIKIN)  -- ＜微菌＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  -- 강제(FAQ 1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,s.germ,tp,LOCATION_TRASH,0,1,1,nil)
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and not x:GetCharm() end,tp,LOCATION_SZONE,0,1,1,e:GetHandler())
  end)
  e1:SetOperation(function(e,tp)
    local ch,host
    for tc in Duel.GetTargets():Iter() do
      if tc:IsLocation(LOCATION_TRASH) then ch=ch or tc elseif tc:IsLocation(LOCATION_SZONE) then host=host or tc end
    end
    if ch and host and ch:IsRelateToEffect(e) and host:IsRelateToEffect(e) and not host:GetCharm() then Duel.Charm(ch,host) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
