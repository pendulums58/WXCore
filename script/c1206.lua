-- WD11-006 マカロン・バグズ
-- 対戦相手のシグニ１体を対象とし、手札から＜凶蟲＞のシグニを好きな枚数捨てる。ターン終了時まで、それのパワーを、この方法で捨てたシグニのレベルを合計した数だけ－2000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  -- 버리기는 대상을 고른 뒤의 처리(FAQ 1)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    local filter=aux.ClassFilter(0,RACE_KYOUCHU)
    local g=Duel.SelectDiscard(tp,0,Duel.GetMatchingGroup(filter,tp,LOCATION_HAND,0,nil):GetCount(),filter)
    local lv=0
    for x in g:Iter() do lv=lv+x:GetLevel() end
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT+REASON_DISCARD) end
    if lv>0 and tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-2000*lv) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e1)
end
