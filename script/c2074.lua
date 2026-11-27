-- WX05-002 花代・伍
-- 【グロウ】あなたのセンタールリグがカード名に《花代》を含む
-- 【常】：このルリグはあなたのルリグトラッシュにあるルリグの【起】能力を持つ。
-- 【常】：あなたのシグニは【ダブルクラッシュ】を得る。
-- 【起】エクシード５：対戦相手のシグニを、パワーの合計が30000以下になるように好きな数対象とし、それらをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- 【グロウ】 센터 루리그 이름에 《花代》(aux.NameHas)
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetCode(EFFECT_GROW_PROC)
  e0:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
      local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
      return lc and aux.NameHas(lc,"花代")
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
  -- [の間] 【常】
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EFFECT_DOUBLE_CRUSH)
  e2:SetRange(LOCATION_LRIG)
  e2:SetTargetRange(LOCATION_SZONE,0)
  e2:SetTarget(function(e,x) return (Card.IsSigni)(x) end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetRange(LOCATION_LRIG)
  e3:SetExceedCost(5)
  -- 고를 때의 파워 합계. 함께 바니시(FAQ 4·5)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetSelectCheck(function(g)
      local n=0
      for x in g:Iter() do n=n+x:GetPower() end
      return n<=30000
    end)
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,3,nil)
  end)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e3)
end
