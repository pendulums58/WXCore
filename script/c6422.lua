-- WXK03-048 師の遊　ボウピン
-- 【自】：あなたのアタックフェイズ開始時、《白》《白》《無》《無》を支払い、このシグニを場からトラッシュに置いてもよい。そうした場合、あなたのすべてのシグニを場から手札に戻す。この方法で＜遊具＞のシグニ２体が手札に戻った場合、あなたのデッキの上からカードを４枚見る。その中から＜遊具＞のシグニを３枚まで場に出し、好きな枚数を好きな順番でデッキの一番下に置き、残りを好きな順番でデッキの一番上に戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e1:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    if not (Duel.CanPayEna(tp,"{W}{W}{C}{C}") and h:IsLocation(LOCATION_SZONE) and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{W}{W}{C}{C}"),REASON_COST)
    if Duel.SendToTrash(h,REASON_EFFECT)==0 then return end
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil)
    if g:GetCount()==0 then return end
    Duel.SendToHand(g)
    local n=g:Filter(function(x) return x:IsLocation(LOCATION_HAND) and x:IsClass(0,RACE_YUGU) end,nil):GetCount()
    if n<2 then return end
    local d=Duel.GetDecktopGroup(tp,4)
    if d:GetCount()==0 then return end
    Duel.ConfirmCards(tp,d)
    for x in Duel.SelectCards(tp,d:Filter(function(x) return x:IsSigni() and x:IsClass(0,RACE_YUGU) end,nil),0,3):Iter() do Duel.PutOnField(x,tp) end
    local rest=d:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()==0 then return end
    local bot=Duel.SelectCards(tp,rest,0,rest:GetCount())
    local top=rest:Filter(function(y) return not bot:IsContains(y) end,nil)
    if bot:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,bot),false) end
    if top:GetCount()>0 then aux.ToDeckTopInOrder(tp,top) end
  end)
  c:RegisterEffect(e1)
end
