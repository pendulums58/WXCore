-- WXK10-088 幻竜　ボティス
-- 【出】：あなたのデッキの上からカードを３枚トラッシュに置く。この方法で＜龍獣＞のシグニが３枚トラッシュに置かれた場合、ターン終了時まで、このシグニは【ランサー】を得る。
-- （【ランサー】を持つシグニがバトルでシグニをバニッシュしたとき、対戦相手のライフクロスを１枚クラッシュする）
-- 【起】手札から＜龍獣＞のシグニを１枚捨てる：ターン終了時まで、このシグニのパワーを＋3000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    local h=e:GetHandler()
    if g:Filter(function(x) return x:IsSigni() and x:IsClass(0,RACE_RYUJU) end,nil):GetCount()==3 and h:IsLocation(LOCATION_SZONE) then aux.GrantKeyword(e,h,EFFECT_LANCER) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCost(aux.DiscardCost(1,function(x) return x:IsSigni() and x:IsClass(0,RACE_RYUJU) end))
  e2:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then aux.AddPower(e,h,3000) end
  end)
  c:RegisterEffect(e2)
end
