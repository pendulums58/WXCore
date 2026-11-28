-- WXK01-120 サーバント　Ｔ４
-- 【ガード】（このカードを手札から捨てることで、ルリグのアタックによるダメージを一度防ぐ）
-- 【常】：【マルチエナ】（エナコストを支払う際、このカードは好きな色１つとして支払える）
-- ライフバースト：あなたのトラッシュから＜精元＞のシグニ１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 에나 존에서만(용어집: マルチエナ)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_MULTI_ENA)
  e1:SetRange(LOCATION_ENA)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,aux.ClassFilter(SYS_SEIGEN,0),tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToHand(tc)
    end
  end)
  c:RegisterEffect(e9)
end
