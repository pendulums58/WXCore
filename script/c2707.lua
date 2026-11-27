-- WX14-047 未来の噴陰　†アークホールド†
-- 【起】《ダウン》他の＜天使＞のシグニ１体を場からトラッシュに置く：あなたのデッキからこの方法でトラッシュに置いたシグニと共通する色を持つ、《未来の噴陰　†アークホールド†》以外のレベル４以下のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local h=e:GetHandler()
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,tp,LOCATION_SZONE,0,h)
    if chk==0 then return h:IsUp() and g:GetCount()>0 end
    Duel.Down(h,REASON_COST)
    local x=Duel.SelectCards(tp,g,1,1):GetFirst()
    e:SetLabel(x:GetColor())
    Duel.SendToTrash(x,REASON_COST)
  end)
  e1:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and x:GetColor()&e:GetLabel()~=0 and x:GetLevel()<=4 and not x:IsCardName(id) end,1)
  end)
  c:RegisterEffect(e1)
end
