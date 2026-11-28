-- WXK07-070 羅菌　サイコラ
-- 【出】：あなたのシグニを２体まで対象とし、あなたのデッキの上からカードを２枚まで、それらの【チャーム】にする。
-- （【チャーム】は裏向きでシグニに付き、１体に１枚までしか付けられない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and not x:GetCharm() end,tp,LOCATION_SZONE,0,0,2,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    for x in Duel.GetTargets():Iter() do
      local top=Duel.GetDecktopGroup(tp,1):GetFirst()
      if top and x:IsRelateToEffect(e) and x:IsLocation(LOCATION_SZONE) and not x:GetCharm() then Duel.Charm(top,x) end
    end
  end)
  c:RegisterEffect(e1)
end
