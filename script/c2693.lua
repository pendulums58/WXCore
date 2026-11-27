-- WX14-032 サーバント　∞
-- 【常】：【マルチエナ】
-- 【出】：メインデッキ、手札、シグニゾーン、トラッシュのいずれか１つを指定する。
-- 【常】：このシグニの【出】能力で指定された領域にある対戦相手のシグニであるカードはクラスと色を失い、＜精元＞を得る。
-- ライフバースト：あなたのトラッシュから《ガードアイコン》を持つシグニを２枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_MULTI_ENA)
  e1:SetRange(LOCATION_ENA)
  c:RegisterEffect(e1)
  -- 【出】의 영역 지정과 「クラスと色を失い、＜精元＞を得る」는 아직(근사 없음)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:HasGuardIcon() end,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e2)
end
