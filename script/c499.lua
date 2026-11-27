-- WX22-Re07 コードアンチ　ニャルクト
-- 【自】：このシグニがアタックしたとき、あなたのデッキの上からカードを３枚トラッシュに置く。その後、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーをこの方法でトラッシュに置かれた黒のシグニ１枚につき－3000する。
-- 【出】：あなたのデッキの一番上のカードをトラッシュに置く。それが＜古代兵器＞のシグニの場合、それをトラッシュから場に出してもよい。
-- ライフバースト：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーをあなたのトラッシュにあるカード１枚につきー1000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    local n=g:Filter(function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,nil):GetCount()
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc and n>0 then aux.AddPower(e,tc,-3000*n) end  -- [まで]
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local x=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not x then return end
    Duel.SendToTrash(x,REASON_EFFECT)
    if (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KODAIHEIKI)) end)(x) and x:IsLocation(LOCATION_TRASH) and Duel.SelectYesNo(tp) then Duel.PutOnField(x,tp) end
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
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-1000*Duel.GetMatchingGroup(nil,tp,LOCATION_TRASH,0,nil):GetCount()) end
  end)  -- [まで]
  c:RegisterEffect(e3)
end
