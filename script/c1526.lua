-- WDK04-014 大罠　ジャバウォック
-- 【自】：このシグニがアタックしたとき、このシグニが中央のシグニゾーンにある場合、あなたのデッキの一番上を公開する。それをデッキの一番下に置いてもよい。この方法で公開したカードがレベルが奇数のシグニの場合、ターン終了時まで、このシグニのパワーは＋5000され、このシグニは【ランサー】を得る。
-- （【ランサー】を持つシグニがバトルでシグニをバニッシュしたとき、対戦相手のライフクロスを１枚クラッシュする）
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  -- 무엇이 나와도 아래에 놓을 수 있다(FAQ 1)
  e1:SetOperation(function(e,tp)
    local h,top=e:GetHandler(),Duel.GetDecktopGroup(tp,1):GetFirst()
    if not top or not h:IsInZone("signi_center") then return end
    Duel.RevealCards(top)
    if Duel.SelectYesNo(tp) then Duel.SendToDeckBottom(top,false) end
    if not top:IsSigni() or aux.RefLevel(tp,top)%2==0 then return end
    -- [まで] ターン終了時まで
    aux.AddPower(e,h,5000)
    aux.GrantKeyword(e,h,EFFECT_LANCER)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
