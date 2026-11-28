-- WXK02-039 メイル・ストリーム
-- あなたのトラッシュからすべての＜武勇＞のシグニをデッキに加えてシャッフルする。この方法で１５枚以上のカードをデッキに加えた場合、あなたのデッキの一番上のカードをライフクロスに加える。
-- ライフバースト：あなたのトラッシュからカード１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_BUYU) end,tp,LOCATION_TRASH,0,nil)
    local n=g:GetCount()
    Duel.SendToDeckShuffle(g,tp)
    if n>=15 then
      local t=Duel.GetDecktopGroup(tp,1)
      if t:GetCount()>0 then Duel.SendToLife(t) end
    end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToHand(tc)
    end
  end)
  c:RegisterEffect(e9)
end
