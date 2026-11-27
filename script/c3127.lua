-- WX20-037 暴食の暴君　トウタク
-- 【ライズ】あなたの赤のシグニ２体の上に置く（どちらかのシグニがあるシグニゾーンに出す）
-- 【出】：あなたのデッキの上からカードを３枚見る。その中から赤のシグニを２枚まで場に出し、残りをトラッシュに置く。
-- 【起】このシグニの下からカード２枚をトラッシュに置く：ターン終了時まで、このシグニは【ダブルクラッシュ】を得る。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  -- 【ライズ】 「赤のシグニ２体の上」는 1체로 근사
  aux.AddRise(c,function(x) return x:IsSigni() and x:IsColor(COLOR_RED) end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    for x in Duel.SelectCards(tp,g:Filter(function(c) return c:IsSigni() and c:IsColor(COLOR_RED) end,nil),0,2):Iter() do Duel.PutOnField(x,tp) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local u=e:GetHandler():GetUnderGroup()
    if chk==0 then return u:GetCount()>=2 end
    Duel.SendToTrash(Duel.SelectCards(tp,u,2,2),REASON_COST)
  end)
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then aux.GrantKeyword(e,h,EFFECT_DOUBLE_CRUSH) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e3)
end
