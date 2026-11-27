-- WX11-017 ブルー・パニッシュ
-- 以下の４つから２つまで選ぶ。あなたのセンタールリグが＜ピルルク＞の場合、代わりに３つまで選ぶ。
-- ①コストの合計が５以下のスペル１つを対象とし、それの効果を打ち消す。
-- ②対戦相手のシグニ１体を対象とし、それをダウンする。
-- ③対戦相手の手札を１枚見ないで選び、捨てさせる。
-- ④カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,(function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_PIRULUK) end)() and 3 or 2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local m=e:GetLabel()
    s.t1=m&2~=0 and Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() or nil
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m&1~=0 then local sp=Duel.GetCutinSpell() if sp and sp:GetCostTotal()<=5 then Duel.NegateSpell() end end
    if s.t1 and s.t1:IsRelateToEffect(e) then Duel.Down(s.t1) end
    if m&4~=0 then local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil) if g:GetCount()>0 then Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT+REASON_DISCARD) end end
    if m&8~=0 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
end
