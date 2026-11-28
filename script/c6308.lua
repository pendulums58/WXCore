-- WXK02-032 ストラテジー・ゲイル
-- あなたのデッキの上からカードを「７－あなたのライフクロスの枚数」枚見る。その中から１枚を手札に加え、好きな枚数を好きな順番でデッキの一番下に置き、残りを好きな順番でデッキの一番上に戻す。
-- ライフバースト：どちらか１つを選ぶ。①対戦相手のセンタールリグかシグニ１体を対象とし、それをダウンする。②カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    -- 0장 이하면 아무것도 하지 않는다(FAQ 1)
    local n=7-Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()
    if n<=0 then return end
    local g=Duel.GetDecktopGroup(tp,n)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    Duel.SendToHand(Duel.SelectCards(tp,g,1,1))
    local rest=g:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()==0 then return end
    local bot=Duel.SelectCards(tp,rest,0,rest:GetCount())
    local top=rest:Filter(function(y) return not bot:IsContains(y) end,nil)
    if bot:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,bot),false) end
    if top:GetCount()>0 then aux.ToDeckTopInOrder(tp,top) end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e9:SetOperation(function(e,tp,eg)
    if e:GetLabel()==1 then Duel.Draw(tp,1) return end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() or x:IsLocation(LOCATION_LRIG) end,tp,0,LOCATION_SZONE+LOCATION_LRIG,1,1,nil):GetFirst()
    if tc then Duel.Down(tc) end
  end)
  c:RegisterEffect(e9)
end
