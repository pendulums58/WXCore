-- WX16-071 木英の文章　＃ウエキ＃
-- 【出】英知=１：あなたのデッキの一番上を公開する。それが＜英知＞のシグニの場合、手札に加える。（あなたの場にある＜英知＞のシグニのレベルの合計がちょうど１であるかぎり有効になる）
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCondition(aux.EichiCon(1))
  e1:SetOperation(function(e,tp)
    local x=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not x then return end
    Duel.RevealCards(Group.CreateGroup(x))
    if (function(x) return x:IsSigni() and (x:IsClass(0,RACE_EICHI)) end)(x) then Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
