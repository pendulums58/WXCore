-- WXK02-003 来夢の巫女　リメンバ・ミッドナイト
-- 【自】：あなたのアタックフェイズ開始時、デッキの上からカードを３枚見る。その中から好きな枚数を好きな順番でデッキの一番下に置き、残りを好きな順番でデッキの一番上に戻す。
-- 【出】《青》：対戦相手のシグニを２体まで対象とし、それらを凍結する。カードを２枚引く。
-- 【起】《ゲーム１回》アストロジ《コインアイコン》：対戦相手の手札と対戦相手のライフクロスの一番上を見る。カードを２枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local bot=Duel.SelectCards(tp,g,0,g:GetCount())
    local top=g:Filter(function(x) return not bot:IsContains(x) end,nil)
    if bot:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,bot),false) end
    if top:GetCount()>0 then aux.ToDeckTopInOrder(tp,top) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{U}")
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    for x in Duel.GetTargets():Iter() do if x:IsRelateToEffect(e) then Duel.Freeze(x) end end
    Duel.Draw(tp,2)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(1,true)
  e3:SetCoinCost(1)
  e3:SetOperation(function(e,tp,eg)
    -- 나만 본다(FAQ 3)
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    local top=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LIFE,nil):GetFirst()
    if top then g:AddCard(top) end
    if g:GetCount()>0 then Duel.ConfirmCards(tp,g) end
    Duel.Draw(tp,2)
  end)
  c:RegisterEffect(e3)
end
