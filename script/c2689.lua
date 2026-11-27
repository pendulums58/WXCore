-- WX14-026 羅石　スイカリン
-- 【常】：対戦相手のターンの間、このシグニがバニッシュされる場合、代わりにあなたのライフクロス１枚をクラッシュしてもよい。
-- 【出】：あなたは手札を１枚捨てる。この方法で捨てたカードが＜鉱石＞か＜宝石＞のシグニで、あなたのセンタールリグが赤の場合、ターン終了時まで、このシグニは【アサシン】を得る。
-- ライフバースト：カードを１枚引く。その後、あなたのライフクロス１枚をクラッシュしてもよい。そうした場合、追加でカードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  -- 【常】 「代わりにライフクロス１枚をクラッシュしてもよい」는 아직(근사 없음)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    if g:GetCount()==0 then return end
    local x=Duel.SelectCards(tp,g,1,1):GetFirst()
    if Duel.SendToTrash(x,REASON_EFFECT+REASON_DISCARD)==0 then return end
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    local h=e:GetHandler()
    if (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KOUSEKI) or x:IsClass(0,RACE_HOUSEKI)) end)(x) and lc and lc:IsColor(COLOR_RED) and h:IsLocation(LOCATION_SZONE) then aux.GrantKeyword(e,h,EFFECT_ASSASSIN) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()>0 and Duel.SelectYesNo(tp) and Duel.Crush(tp,1):GetCount()>0 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e2)
end
