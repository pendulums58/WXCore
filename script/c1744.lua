-- WDK13-012 羅星 ホースヘッド
-- 【起】《ダウン》：あなたのデッキの上からカードを４枚公開する。その後、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーをこの方法で公開されたシグニのレベルの合計１につき－1000する。公開したカードをシャッフルしてデッキの一番下に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  -- 3장 이하면 전부. 덱 아래로 가므로 리프레시는 없다(FAQ 1)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,4)
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local lv=0
    for x in g:Iter() do if x:IsSigni() then lv=lv+x:GetLevel() end end
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc and lv>0 then aux.AddPower(e,tc,-1000*lv) end  -- [まで] ターン終了時まで
    Duel.SendToDeckBottom(g,true)
  end)
  c:RegisterEffect(e1)
end
