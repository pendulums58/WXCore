-- WD23-039-A 小罠　テイチアミ
-- 【常】：このシグニと同じシグニゾーンに【トラップ】があるかぎり、このシグニの基本パワーは5000になる。
-- 【トラップアイコン】：《青》《青》を支払ってもよい。そうした場合、あなたのデッキからレベル２以下の＜トリック＞のシグニ１枚を探して場に出し、デッキをシャッフルする。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 같은 존에 【トラップ】이 있는 동안. 기본 파워라 ±는 그 위에 더해진다(FAQ 1)
  aux.BasePower(c,5000,function(e)
    local z=e:GetHandler():GetZone()
    return z~=nil and Duel.GetTrap(z)~=nil
  end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_TRAP)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetOperation(function(e,tp)
    if not (Duel.CanPayEna(tp,"{U}{U}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{U}{U}"),REASON_COST)
    local tc=aux.Search(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_TRICK) and x:IsLevelBetween(0,2) end,1):GetFirst()
    if tc then Duel.PutOnField(tc,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
