-- WX05-003 コード・ピルルク　ＡＣＲＯ
-- 【グロウ】あなたのセンタールリグがカード名に《ピルルク》を含む
-- 【常】：このルリグはあなたのルリグトラッシュにあるルリグの【起】能力を持つ。
-- 【出】：対戦相手は手札をすべて捨てる。
-- 【起】エクシード5：あなたの手札が６枚より少ない場合、その差の分だけカードを引く。
local s,id=GetID()
function s.initial_effect(c)
  -- 【グロウ】 센터 루리그 이름에 《ピルルク》(aux.NameHas)
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetCode(EFFECT_GROW_PROC)
  e0:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
      local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
      return lc and aux.NameHas(lc,"ピルルク")
    end
  end)
  c:RegisterEffect(e0)
  -- [の間] 【常】 루리그 트래시 루리그의 【起】를 가진다(FAQ 2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_LTRASH_IGNITION)
  e1:SetRange(LOCATION_LRIG)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT+REASON_DISCARD) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetRange(LOCATION_LRIG)
  e3:SetExceedCost(5)
  e3:SetOperation(function(e,tp)
    local n=6-Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()
    if n>0 then Duel.Draw(tp,n) end
  end)
  c:RegisterEffect(e3)
end
