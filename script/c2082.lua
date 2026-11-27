-- WX05-015 ヘイト・インプレス
-- あなたの＜毒牙＞のシグニ１体を場からトラッシュに置く。そうした場合、ターン終了時まで、対戦相手のすべてのシグニのパワーをこの方法でトラッシュに置いたシグニのレベル１につき－2000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_DOKUGA)) end,tp,LOCATION_SZONE,0,nil)
    local x=Duel.SelectCards(tp,g,1,1):GetFirst()
    if not x then return end
    local lv=x:GetLevel()
    if Duel.SendToTrash(x,REASON_EFFECT)==0 then return end
    -- [まで] 처리할 때 장에 있는 시그니만
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do aux.AddPower(e,tc,-2000*lv) end
  end)
  c:RegisterEffect(e1)
end
