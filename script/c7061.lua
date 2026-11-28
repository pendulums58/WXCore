-- WXK10-087 魏軍の果断　ガクシン
-- 【出】手札から＜武勇＞のシグニを１枚捨てる：あなたのデッキの上からカードを３枚トラッシュに置く。その後、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーをこの方法でトラッシュに置かれた＜武勇＞のシグニ１枚につき－1000する。
-- （パワーが０以下のシグニはルールによってバニッシュされる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(aux.DiscardCost(1,function(x) return x:IsSigni() and x:IsClass(0,RACE_BUYU) end))
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    local n=g:Filter(function(x) return x:IsSigni() and x:IsClass(0,RACE_BUYU) end,nil):GetCount()
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc and n>0 then aux.AddPower(e,tc,-1000*n) end
  end)
  c:RegisterEffect(e1)
end
