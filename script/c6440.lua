-- WXK03-066 景英の高騰　バブリー
-- 【出】《青》《青》：あなたのライフクロス１枚をトラッシュに置く。そうした場合、あなたのデッキの一番下のカードをライフクロスに加える。
-- （ライフクロスのカードを移動させる場合は上から順番に加えたり減らしたりする）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  -- 크래시가 아니다(FAQ 1·2)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{U}{U}")
  e1:SetOperation(function(e,tp,eg)
    local x=Duel.GetLifetopGroup(tp,1):GetFirst()
    if not x or Duel.SendToTrash(x,REASON_EFFECT)==0 then return end
    local b=Duel.GetDeckbottomGroup(tp,1)
    if b:GetCount()>0 then Duel.SendToLife(b) end
  end)
  c:RegisterEffect(e1)
end
