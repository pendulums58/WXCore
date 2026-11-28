-- WDK12-013 羅菌 ビオチン
-- 【常】：あなたのターンの間、【チャーム】が付いているあなたのシグニのパワーを＋3000する。
-- 【起】《ターン２回》《緑》：あなたのトラッシュから対象の＜微菌＞のシグニ１枚を対象のあなたのシグニ１体の【チャーム】にする。
local s,id=GetID()
s.germ=aux.ClassFilter(0,RACE_BIKIN)  -- ＜微菌＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】 자신도 포함(FAQ 1)
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x:IsSigni() and x:GetCharm()~=nil end)
  e1:SetCondition(function(e) return Duel.GetTurnPlayer()==e:GetHandlerPlayer() end)
  e1:SetValue(3000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(2)
  e2:SetEnaCost("{G}")
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,s.germ,tp,LOCATION_TRASH,0,1,1,nil)
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and not x:GetCharm() end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local ch,host
    for tc in Duel.GetTargets():Iter() do
      if tc:IsLocation(LOCATION_TRASH) then ch=ch or tc elseif tc:IsLocation(LOCATION_SZONE) then host=host or tc end
    end
    if ch and host and ch:IsRelateToEffect(e) and host:IsRelateToEffect(e) and not host:GetCharm() then Duel.Charm(ch,host) end
  end)
  c:RegisterEffect(e2)
end
