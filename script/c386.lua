-- PR-K064 コードアンチ　ラティナ（カードゲーマー vol.48 付録）
-- 【出】アップ状態のセンタールリグ１体をダウンする：以下の３つから１つを選ぶ。
-- ①あなたのデッキからあなたのセンタールリグと共通する色を持つシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- ②対戦相手のレベル３以下のシグニ１体を対象とし、それを手札に戻す。
-- ③対戦相手の手札を１枚見ないで選び、捨てさせる。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if chk==0 then return lc~=nil and lc:IsUp() end
    Duel.Down(lc,REASON_COST)
  end)
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m==0 then
      local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
      local col=lc and lc:GetColor() or 0
      local g=aux.Search(tp,function(x) return x:IsSigni() and x:GetColor()&col~=0 end,1)
      if g:GetCount()>0 then
        Duel.RevealCards(g)
        Duel.SendToHand(g)
      end
      aux.ShuffleDeck(tp)
    elseif m==1 then
      local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.SendToHand(tc) end
    else
    local h=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    if h:GetCount()>0 then Duel.SendToTrash(Duel.SelectCards(tp,h,1,1),REASON_EFFECT+REASON_DISCARD) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
