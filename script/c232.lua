-- WX11-020 因果応報
-- このアーツの使用コストはあなたのセンタールリグのレベル１につき《無×2》減る。
-- 対戦相手のエナゾーンにあるすべての、白、赤、青、緑、黒のカードと対戦相手の場にあるすべてのシグニをトラッシュに置く。あなたのセンタールリグが＜緑子＞の場合、追加で対戦相手のエナゾーンにあるすべてのカードをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return Duel.ReduceCost(base,"{C}",2*(lc and lc:GetLevel() or 0)) end)
  e1:SetOperation(function(e,tp)
    local all=(function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_MIDORIKO) end)()
    local g=Duel.GetMatchingGroup(function(x) return all or x:GetColor()~=0 end,tp,0,LOCATION_ENA,nil)
    g:Merge(Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil))
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
end
