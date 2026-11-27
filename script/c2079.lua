-- WX05-010 エルドラ＝マークⅤ
-- 【グロウ】あなたのセンタールリグがカード名に《エルドラ》を含む
-- 【出】：あなたのすべてのライフクロスを見て、その中から好きな枚数をトラッシュに置き、その枚数と同じ枚数のカードをデッキの上からライフクロスに加える。その後、あなたのすべてのライフクロスを見て、好きな順番で並び替える。
-- 【起】エクシード２：あなたのライフクロス１枚をクラッシュする。そうした場合、手札を１枚ライフクロスに加える。
local s,id=GetID()
function s.initial_effect(c)
  -- 【グロウ】 센터 루리그 이름에 《エルドラ》(aux.NameHas)
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetCode(EFFECT_GROW_PROC)
  e0:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
      local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
      return lc and aux.NameHas(lc,"エルドラ")
    end
  end)
  c:RegisterEffect(e0)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local life=Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil)
    if life:GetCount()==0 then return end
    Duel.ConfirmCards(tp,life)
    local g=Duel.SelectCards(tp,life,0,life:GetCount())
    local n=g:GetCount()>0 and Duel.SendToTrash(g,REASON_EFFECT) or 0
    if n>0 then
      local top=Duel.GetDecktopGroup(tp,n)
      if top:GetCount()>0 then Duel.SendToLife(top) end
    end
    life=Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil)
    Duel.ConfirmCards(tp,life)
    aux.ToLifeTopInOrder(tp,life)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_LRIG)
  e2:SetExceedCost(2)
  -- 손패를 더한 뒤에 그 버스트를 처리한다(FAQ 2)
  e2:SetOperation(function(e,tp)
    if Duel.Crush(tp,1):GetCount()==0 then return end
    local h=Duel.SelectCards(tp,Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil),1,1)
    if h:GetCount()>0 then Duel.SendToLife(h) end
  end)
  c:RegisterEffect(e2)
end
