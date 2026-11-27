-- WX16-038 忍猿の十勇　サルトビ
-- 【ライズ】あなたのレベル２以下の赤のシグニ１体の上に置く
-- 【出】：あなたのデッキの一番上を見る。それが《ライズアイコン》を持つ＜武勇＞のシグニの場合、それを場に出してもよい。
-- 【自】：このシグニがライズされたとき、あなたのデッキの一番上を見る。それが《ライズアイコン》を持たない＜武勇＞のシグニの場合、それを場に出してもよい。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddRise(c,function(x) return x:IsSigni() and x:IsColor(COLOR_RED) and x:GetLevel()<=2 end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local x=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not x then return end
    Duel.ConfirmCards(tp,Group.CreateGroup(x))
    if (function(c) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_BUYU)) end)(c) and c:HasRiseIcon() end)(x) and Duel.SelectYesNo(tp) then Duel.PutOnField(x,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_RISEN)
  e2:SetOperation(function(e,tp)
    local x=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not x then return end
    Duel.ConfirmCards(tp,Group.CreateGroup(x))
    if (function(c) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_BUYU)) end)(c) and not c:HasRiseIcon() end)(x) and Duel.SelectYesNo(tp) then Duel.PutOnField(x,tp) end
  end)
  c:RegisterEffect(e2)
end
