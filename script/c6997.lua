-- WXK10-023 乗装　モンケーン
-- 【出】《赤》手札から赤のシグニを１枚捨てる：あなたのデッキからこの方法で捨てたシグニと共通するクラスを持つレベル３以下の赤のシグニを２枚まで探して公開し手札に加え、デッキをシャッフルする。
-- 【起】《ターン１回》アップ状態のセンタールリグ１体をダウンする：対戦相手のパワー12000以下のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：対戦相手のパワー12000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{R}")
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsColor(COLOR_RED) end,tp,LOCATION_HAND,0,nil)
    if chk==0 then return g:GetCount()>0 end
    local x=Duel.SelectCards(tp,g,1,1):GetFirst()
    s.dc=x
    Duel.SendToTrash(x,REASON_COST+REASON_DISCARD)
  end)
  e1:SetOperation(function(e,tp,eg)
    local d0=s.dc
    local g=aux.Search(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 and x:IsColor(COLOR_RED) and (function(a,b) local g=Group.CreateGroup() g:AddCard(a) g:AddCard(b) return aux.ShareClass(g) end)(x,d0) end,2)
    if g:GetCount()>0 then Duel.SendToHand(g) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if chk==0 then return lc and not lc:IsDown() end
    Duel.Down(lc,REASON_COST)
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=12000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.Banish(tc)
    end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=12000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.Banish(tc)
    end
  end)
  c:RegisterEffect(e9)
end
