-- WXK07-087 羅星　クラビュラ
-- 【常】：あなたの場にあるシグニのレベルの合計が対戦相手の場にあるシグニのレベルの合計以下であるかぎり、このシグニのパワーは＋5000される。
-- 【出】《黒》：場にレベル１、レベル２、レベル３、レベル４のシグニがある場合、カードを１枚引く。（対戦相手の場にあるシグニも参照する）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) local tp=e:GetHandlerPlayer() return (function(p) local n=0 for x in Duel.GetMatchingGroup(Card.IsSigni,p,LOCATION_SZONE,0,nil):Iter() do n=n+x:GetLevel() end return n end)(tp)<=(function(p) local n=0 for x in Duel.GetMatchingGroup(Card.IsSigni,p,LOCATION_SZONE,0,nil):Iter() do n=n+x:GetLevel() end return n end)(1-tp) end)
  e1:SetValue(5000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{B}")
  e2:SetOperation(function(e,tp,eg)
    local ok=true
    for lv=1,4 do
      if Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetLevel()==lv end,tp,LOCATION_SZONE,LOCATION_SZONE,nil):GetCount()==0 then ok=false end
    end
    if ok then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e2)
end
