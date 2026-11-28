-- SP24-010 起承転結（「Lostorage incited WIXOSS 2」 初回特典）
-- あなたのデッキから＜調理＞のシグニ１枚を探して場に出し、デッキをシャッフルする。そのシグニの【出】能力は発動しない。あなたのデッキの上からカードを２枚エナゾーンに置く。その後、あなたのエナゾーンから《アクセアイコン》を持つシグニ１枚を対象とし、それをこの方法で場に出したシグニの【アクセ】にしてもよい。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 에나에 놓은 2장도 고를 수 있다(FAQ 1). 낸 시그니가 없으면 붙이지 않는다(FAQ 3)
  e1:SetOperation(function(e,tp)
    local x=aux.Search(tp,function(y) return y:IsSigni() and y:IsClass(0,RACE_CHOURI) end,1):GetFirst()
    local put=x and Duel.PutOnField(x,tp,true) and x or nil
    aux.ShuffleDeck(tp)
    local g=Duel.GetDecktopGroup(tp,2)
    if g:GetCount()>0 then Duel.SendToEna(g) end
    if not (put and put:IsLocation(LOCATION_SZONE)) then return end
    local a=Duel.SelectTarget(tp,function(y) return y:IsSigni() and y:HasAcceIcon() end,tp,LOCATION_ENA,0,0,1,nil):GetFirst()
    if a then Duel.Acce(a,put) end
  end)
  c:RegisterEffect(e1)
end
