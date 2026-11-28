-- WXK10-082 羅菌　オレイン
-- 【起】《ターン１回》あなたの場にある【チャーム】を１枚以上トラッシュに置く：この方法でトラッシュに置いた【チャーム】の枚数と同じレベルを持つ対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Group.CreateGroup()
    for x in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do if x:GetCharm() then g:AddCard(x:GetCharm()) end end
    if chk==0 then return g:GetCount()>0 end
    local sg=Duel.SelectCards(tp,g,1,g:GetCount())
    e:SetLabel(sg:GetCount())
    Duel.SendToTrash(sg,REASON_COST)
  end)
  e1:SetOperation(function(e,tp,eg)
    local n=e:GetLabel()
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()==n end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e9)
end
