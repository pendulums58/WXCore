-- WXK08-026 炎魔の豊穣　シュブ＝ニグラ
-- 【自】《ビートアイコン》［レベル１～４が各１枚以上］：このシグニがアタックしたとき、対戦相手のライフクロス１枚をクラッシュする。
-- 【起】《ビートアイコン》［４枚以下］《ターン１回》他のシグニ１体を【ビート】にする：以下の２つから１つを選ぶ。ターン終了時まで、このシグニは選んだ能力を得る。①【アサシン】②【ダブルクラッシュ】
-- ライフバースト：あなたのトラッシュから＜悪魔＞のシグニを２枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetCondition(aux.BeatCon(aux.BeatLevels))
  e1:SetOperation(function(e,tp,eg)
    Duel.Crush(1-tp,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCondition(aux.BeatCon(function(g) return g:GetCount()<=4 end))
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x~=e:GetHandler() end,tp,LOCATION_SZONE,0,nil)
    if chk==0 then return g:GetCount()>=1 end
    Duel.Beat(Duel.SelectCards(tp,g,1,1),REASON_COST)
  end)
  e2:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    if not h:IsLocation(LOCATION_SZONE) then return end
    if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then aux.GrantKeyword(e,h,EFFECT_ASSASSIN) else aux.GrantKeyword(e,h,EFFECT_DOUBLE_CRUSH) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_AKUMA) end,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e9)
end
