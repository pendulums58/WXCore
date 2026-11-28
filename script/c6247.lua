-- WXK01-064 大罠　ハリテン
-- 【自】：このシグニがアタックしたとき、あなたのデッキの上からカードを２枚トラッシュに置く。その後、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーをこの方法でトラッシュに置かれたシグニのレベルの合計１につき－1000する。
-- ライフバースト：どちらか１つを選ぶ。①対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－3000する。②【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp,eg)
    -- 대상은 트래시에 둔 뒤에(FAQ 2)
    local g=Duel.GetDecktopGroup(tp,2)
    if g:GetCount()==0 then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    local n=0
    for x in g:Iter() do if x:IsSigni() and x:IsLocation(LOCATION_TRASH) then n=n+x:GetLevel() end end
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc and n>0 then aux.AddPower(e,tc,-1000*n) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e9:SetOperation(function(e,tp,eg)
    if e:GetLabel()==1 then Duel.EnaCharge(tp,1) return end
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then aux.AddPower(e,tc,-3000) end
  end)
  c:RegisterEffect(e9)
end
