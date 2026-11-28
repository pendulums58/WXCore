-- WXK03-036 コードライド　フォークローダー
-- 【自】：このシグニがアタックしたとき、あなたのセンタールリグ１体を対象とし、それはすべてのシグニから降りてもよい。
-- （すべてのシグニからルリグが降りるとルリグとシグニはドライブ状態ではなくなり、ルリグはアタックできるようになる）
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  -- 드라이브 상태가 아니면 아무 일도 없다(FAQ 1)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp,eg)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if lc and lc:IsDrive() and Duel.SelectYesNo(tp) then Duel.Unride(tp) end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e9)
end
