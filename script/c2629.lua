-- WX13-058 ドライ＝ダイオ娘
-- 【常】：あなたの場にカード名に《ダイオ姫》を含むシグニがあるかぎり、このシグニは「【起】《ダウン》：このターン、あなたのシグニの効果で対戦相手のシグニのパワーが－（マイナス）される場合、代わりに２倍－（マイナス）される。」を得る。
-- 【起】このシグニを場からトラッシュに置く：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーをあなたのセンタールリグのレベル１につき－1000する。あなたのトラッシュにカード名に《ダイオ姫》を含むシグニがある場合、代わりに対戦相手のすべてのシグニのパワーをあなたのセンタールリグのレベル１につき－1000する。
local s,id=GetID()
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_IGNITION)
  g:SetDescription(aux.Ability(id,0))
  g:SetRange(LOCATION_SZONE)
  g:SetCost(aux.SelfDownCost)
  g:SetOperation(function(e,tp)
    -- [の間] 「このターン」
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_DOUBLE_MINUS)
    e1:SetTargetRange(1,0)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SIGNI,0)
  e1:SetTarget(function(e,x) return x==e:GetHandler() and Duel.GetMatchingGroup(function(a) return aux.NameHas(a,"ダイオ姫") end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0 end)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_SZONE) end
    Duel.SendToTrash(e:GetHandler(),REASON_COST)
  end)
  e2:SetOperation(function(e,tp)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    local v=-1000*(lc and lc:GetLevel() or 0)
    if Duel.GetMatchingGroup(function(a) return aux.NameHas(a,"ダイオ姫") end,tp,LOCATION_TRASH,0,nil):GetCount()>0 then
      for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do aux.AddPower(e,tc,v) end
    else
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then aux.AddPower(e,tc,v) end
    end
  end)
  c:RegisterEffect(e2)
end
