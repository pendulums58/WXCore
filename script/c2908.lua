-- WX17-015 生炎与奪
-- あなたのデッキの上からカードを４枚見て、それらを好きな順番でデッキの一番上に戻す。その後、あなたのデッキの一番上を公開する。この方法で公開したシグニと同じレベルの対戦相手のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,4)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    aux.ToDeckTopInOrder(tp,g)
    local x=Duel.GetDecktopGroup(tp,1):GetFirst()
    Duel.RevealCards(Group.CreateGroup(x))
    if not x:IsSigni() then return end
    local lv=x:GetLevel()
    local tc=Duel.SelectTarget(tp,function(c) return c:IsSigni() and c:GetLevel()==lv end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
end
