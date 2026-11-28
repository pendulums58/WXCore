-- WDK15-015 爆書　カゲシ
-- 【出】《黒》：あなたのシグニの下にある＜ウェポン＞のシグニ１枚を対象とし、それを手札に加える。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
s.weapon=aux.ClassFilter(0,RACE_WEAPON)  -- ＜ウェポン＞のシグニ
s.rise=function(x) return x:IsSigni() and x:HasRiseIcon() and x:IsColor(COLOR_BLACK) end  -- 《ライズアイコン_黒》を持つシグニ
function s.under(tp,f)
  local g=Group.CreateGroup()
  for x in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do
    for u in x:GetUnderGroup():Iter() do if not f or f(u) then g:AddCard(u) end end
  end
  return g
end
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{B}")
  -- 아래에 있는 카드를 대상으로 하는 것은 고르는 것으로 근사
  e1:SetOperation(function(e,tp)
    local g=s.under(tp,s.weapon)
    local tc=g:GetCount()>0 and Duel.SelectCards(tp,g,1,1):GetFirst()
    if tc then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
end
