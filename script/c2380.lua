-- WX10-001 炎・タマヨリヒメ・伍
-- 【グロウ】あなたのセンタールリグがカード名に《タマ》を含む
-- 【起】《ターン１回》エクシード１（白のカード）：対戦相手のシグニ１体を対象とし、それを手札に戻す。
-- 【起】《ターン１回》エクシード１（赤のカード）：対戦相手のパワー15000以下のシグニ１体を対象とし、それをバニッシュする。
-- 【起】エクシード２（白と赤のカード）：あなたのデッキから＜アーム＞と＜ウェポン＞のシグニを１枚ずつ探して場に出し、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- 【グロウ】 센터 루리그 이름에 《タマ》(aux.NameHas)
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetCode(EFFECT_GROW_PROC)
  e0:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
      local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
      return lc and aux.NameHas(lc,"タマ")
    end
  end)
  c:RegisterEffect(e0)
  -- 엑시드로 두는 카드의 색(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(1)
  e1:SetExceedCost(1)
  e1:SetCheck(function(g) return g:GetFirst():IsColor(COLOR_WHITE) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetExceedCost(1)
  e2:SetCheck(function(g) return g:GetFirst():IsColor(COLOR_RED) end)
  e2:SetTarget(aux.BanishPowerTarget(15000))
  e2:SetOperation(aux.BanishOp)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetRange(LOCATION_LRIG)
  e3:SetExceedCost(2)
  e3:SetCheck(function(g)
    local a,b=false,false
    for x in g:Iter() do
      if x:IsColor(COLOR_WHITE) and not a then a=true elseif x:IsColor(COLOR_RED) then b=true end
    end
    return a and b
  end)
  -- 한쪽만 있으면 그것만(FAQ 3)
  e3:SetOperation(function(e,tp)
    for _,f in ipairs({function(x) return x:IsSigni() and (x:IsClass(0,RACE_ARM)) end,function(x) return x:IsSigni() and (x:IsClass(0,RACE_WEAPON)) end}) do
      local x=aux.Search(tp,f,1):GetFirst()
      if x then Duel.PutOnField(x,tp) end
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e3)
end
