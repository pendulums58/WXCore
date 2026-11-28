-- WDK14-008 回心転火
-- アンコール －《コインアイコン》（アンコールコストを追加で支払って使用してもよい。そうした場合、これは追加で「このカードをルリグデッキに戻す。」を得る）
-- あなたのデッキの上からカードを４枚見る。その中から１枚を手札に加え、１枚を【ビート】にし、残りを好きな順番でデッキの一番下に置く。その後、この方法で【ビート】にしたシグニと同じレベルの対戦相手のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetEncore(1)
  -- 패에 먼저 넣고, 남으면 1장을 【ビート】로. 스펠을 【ビート】로 하면 바니시하지 않는다(FAQ 3·4)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,4)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local h=Duel.SelectCards(tp,g,1,1)
    Duel.SendToHand(h)
    local rest=g:Filter(function(x) return x:IsLocation(LOCATION_MDECK) end,nil)
    local b=rest:GetCount()>0 and Duel.SelectCards(tp,rest,1,1):GetFirst()
    if b then Duel.Beat(b) end
    rest=g:Filter(function(x) return x:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
    if not (b and b:IsLocation(LOCATION_BEAT) and b:IsSigni()) then return end
    local lv=b:GetLevel()
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()==lv end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
end
