-- SP26-008 熾々奮迅（「Lostorage incited WIXOSS 6」 初回特典）
-- このアーツの使用コストはあなたのセンタールリグのレベル１につき《赤×1》減る。
-- あなたの赤のシグニ１体を対象とし、ターン終了時まで、それは【アサシン】を得る。あなたのライフクロスが２枚以下の場合、追加でターン終了時まで、それは【ダブルクラッシュ】を得る。あなたのライフクロスが０枚の場合、追加でターン終了時まで、それは「【自】《ターン１回》：このシグニがアタックしたとき、このシグニをアップする。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return Duel.ReduceCost(base,"{R}",lc and lc:GetLevel() or 0) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_RED) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  -- 쓴 때의 라이프 클로스로 정한다(FAQ 2)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    local life=Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()
    -- [まで] ターン終了時まで
    aux.GrantKeyword(e,tc,EFFECT_ASSASSIN)
    if life<=2 then aux.GrantKeyword(e,tc,EFFECT_DOUBLE_CRUSH) end
    if life>0 then return end
    local g=Effect.CreateEffect(e:GetHandler())
    g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    g:SetDescription(aux.Stringid(id,0))
    g:SetCode(EVENT_ATTACK)
    g:SetCountLimit(1)
    g:SetOperation(function(e2) local h=e2:GetHandler() if h:IsLocation(LOCATION_SZONE) then Duel.Up(h) end end)
    g:SetReset(RESET_PHASE+PHASE_END)
    tc:GrantEffect(g)
  end)
  c:RegisterEffect(e1)
end
