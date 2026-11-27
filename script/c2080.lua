-- WX05-011 ミルルン・ティコ
-- 【グロウ】あなたのセンタールリグがカード名に《ミルルン》を含む
-- 【常】：対戦相手はスペルを使用できない。
-- 【起】エクシード１：あなたのデッキの上からカードを５枚見る。その中から好きな枚数を好きな順番でデッキの一番下に置き、残りを好きな順番でデッキの一番上に戻す。
-- 【起】エクシード２：対戦相手のトラッシュからスペル１枚を対象とし、それをあなたの手札にあるかのようにコストを支払わずに限定条件を無視して使用してもよい。
local s,id=GetID()
function s.initial_effect(c)
  -- 【グロウ】 센터 루리그 이름에 《ミルルン》(aux.NameHas)
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetCode(EFFECT_GROW_PROC)
  e0:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
      local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
      return lc and aux.NameHas(lc,"ミルルン")
    end
  end)
  c:RegisterEffect(e0)
  -- [の間] 【常】 ライフバースト는 사용이 아니다(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_CANNOT_USE)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(0,1)
  e1:SetTarget(function(e,x) return x:IsType(TYPE_SPELL) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_LRIG)
  e2:SetExceedCost(1)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,5)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local b=Duel.SelectCards(tp,g,0,g:GetCount())
    if b:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,b),false) end
    local rest=g:Filter(function(x) return not b:IsContains(x) end,nil)
    if rest:GetCount()>0 then aux.ToDeckTopInOrder(tp,rest) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetRange(LOCATION_LRIG)
  e3:SetExceedCost(2)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_SPELL) end,tp,0,LOCATION_TRASH,1,1,nil)
  end)
  -- 쓰면 상대 트래시로(FAQ 2)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.SelectYesNo(tp) then Duel.UseFree(tc,tp) end
  end)
  c:RegisterEffect(e3)
end
