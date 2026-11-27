-- WX15-053 ＳＬＡＳＨ　ＯＵＴ
-- カードを３枚引き、手札を１枚捨てる。
-- 【トラップアイコン】：対戦相手のシグニ１体を対象とし、あなたの場にある他の【トラップ】１枚をトラッシュに置き、《青》を支払ってもよい。そうした場合、それをバニッシュする。
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②あなたのデッキの上からカードを２枚見て好きな枚数を【トラップ】として設置し、残りをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,3)
    aux.Discard(tp,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_TRAP)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_TRAP,0,e:GetHandler())
    if g:GetCount()==0 or not Duel.CanPayEna(tp,"{U}") or not Duel.SelectYesNo(tp) then return end
    Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT)
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{U}"),REASON_COST)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e3:SetOperation(function(e,tp)
    if e:GetLabel()==0 then Duel.Draw(tp,1) return end
    local g=Duel.GetDecktopGroup(tp,2)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    for x in Duel.SelectCards(tp,g,0,2):Iter() do Duel.SetTrap(x,tp) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e3)
end
