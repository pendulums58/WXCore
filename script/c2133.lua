-- WX05-080 使命の怠惰　ヘカーテ
-- 【起】《ダウン》：あなたの＜悪魔＞のシグニ１体を対象とし、このシグニをそれの【チャーム】にする。
-- （【チャーム】は裏向きでシグニに付き、１体に１枚までしか付けられない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_AKUMA)) end)(x) and not x:GetCharm() end,tp,LOCATION_SZONE,0,1,1,e:GetHandler())
  end)
  e1:SetOperation(function(e,tp)
    local tc,h=Duel.GetFirstTarget(),e:GetHandler()
    if tc and tc:IsRelateToEffect(e) and h:IsLocation(LOCATION_SZONE) then Duel.Charm(h,tc) end
  end)
  c:RegisterEffect(e1)
end
