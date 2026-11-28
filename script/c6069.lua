-- WXEX1-35 神聖なる美将　ジャンヌ
-- 【ライズ】あなたのレベル３以下の赤のシグニ１体にトラッシュにあるそれぞれレベルの異なる赤のシグニ３枚を重ね、その上に置く
-- 【常】：このシグニはあなたの場に《ライズアイコン》を持つシグニが３体あるかぎり、「【常】：対戦相手のアーツの効果を受けない。」を得る。
-- 【自】《ターン１回》：このシグニがアタックしたとき、この下からカード２枚をトラッシュに置いてもよい。そうした場合、このシグニをアップする。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- トラッシュから3枚重ねる複合ライズはまだ(単体ライズで近似)
  aux.AddRise(c,function(x) return x:IsSigni() and x:IsColor(COLOR_RED) and x:GetLevel()<=3 end)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e)
    return Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:HasRiseIcon() end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>=3
  end)
  e1:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and sc and sc:IsType(TYPE_ARTS) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ATTACK)
  e2:SetCountLimit(1)
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    local ug=h:GetUnderGroup()
    if ug:GetCount()<2 or not Duel.SelectYesNo(tp) then return end
    local pick=Duel.SelectCards(tp,ug,2,2)
    if pick:GetCount()==2 and Duel.SendToTrash(pick,REASON_EFFECT)==2 then Duel.Up(h) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e9:SetOperation(aux.BanishOp)
  c:RegisterEffect(e9)
end
