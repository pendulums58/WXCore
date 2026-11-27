-- WX12-004 龍導波
-- 対戦相手のシグニ１体を対象とし、あなたのライフクロス１枚をクラッシュする。そうした場合、それをバニッシュする。あなたのセンタールリグが＜ユヅキ＞で、この方法でクラッシュしたカードが【ライフバースト】を持っていた場合、あなたのデッキの一番上のカードをライフクロスに加える。（ライフバーストはアーツの処理後に発動する）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local c=Duel.Crush(tp,1):GetFirst()
    if not c then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
    if (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_YUZUKI) end)() and c:IsLifeBurst() then local d=Duel.GetDecktopGroup(tp,1) if d:GetCount()>0 then Duel.SendToLife(d) end end
  end)
  c:RegisterEffect(e1)
end
