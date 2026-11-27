-- WX20-029 狩魔の行進　バルバァト
-- 【自】：このシグニがアタックしたとき、あなたのトラッシュから好きな枚数の＜悪魔＞のシグニを対象とし、それらをデッキに加えてシャッフルする。その後、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーをこの方法でデッキに加えたカード１枚につき－1000する。
-- 【出】：あなたのデッキの上からカードを６枚トラッシュに置く。この方法で＜悪魔＞のシグニが５枚以上トラッシュに置かれた場合、カードを２枚引く。
-- ライフバースト：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－10000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local g=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_AKUMA)) end,tp,LOCATION_TRASH,0,nil),0,40)
    local n=g:GetCount()
    if n>0 then Duel.SendToDeckShuffle(g,tp) end
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc and n>0 then aux.AddPower(e,tc,-1000*n) end  -- [まで]
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,6)
    if g:GetCount()==0 then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    if g:Filter(function(x) return x:IsSigni() and (x:IsClass(0,RACE_AKUMA)) end,nil):GetCount()>=5 then Duel.Draw(tp,2) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-10000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e3)
end
