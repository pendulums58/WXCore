-- WXK03-018 隣合の冥者　ハナレ
-- 【常】：あなたのセンタールリグは以下の能力を得る。
-- 【起】《ターン１回》エクシード１（あなたのルリグの下からカードを１枚ルリグトラッシュに置く）：対戦相手のシグニ１体を対象とし、あなたのシグニ１体をバニッシュする。そうした場合、ターン終了時まで、それのパワーをこの方法でバニッシュしたシグニのパワーと同じだけ－（マイナス）する。
-- 【常】：対戦相手の効果によって、対戦相手のシグニのパワーは＋（プラス）されない。
-- 【起】《ターン１回》《黒×0》：あなたの黒のシグニ１体を対象とし、ターン終了時まで、それのパワーを＋5000する。
local s,id=GetID()
function s.initial_effect(c)
  do
    local g=Effect.CreateEffect(c)
    g:SetType(EFFECT_TYPE_IGNITION)
    g:SetDescription(aux.Ability(id,1))
    g:SetRange(LOCATION_LRIG)
    g:SetExceedCost(1)
    g:SetCountLimit(1)
    g:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
      if chk==0 then return true end
      Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
    end)
    g:SetOperation(function(e,tp)
      local tc=Duel.GetFirstTarget()
      local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil)
      if g:GetCount()==0 then return end
      local x=Duel.SelectCards(tp,g,1,1):GetFirst()
      local pw=x:GetPower()
      if Duel.Banish(x)>0 and tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-pw) end
    end)
    local e91=Effect.CreateEffect(c)
    e91:SetType(EFFECT_TYPE_FIELD)
    -- [の間] 【常】 센터 루리그가 얻는다
    e91:SetDescription(aux.Ability(id,0))
    e91:SetCode(EFFECT_GRANT)
    e91:SetRange(LOCATION_KEY)
    e91:SetTargetRange(LOCATION_LRIG,0)
    e91:SetLabelObject(g)
    c:RegisterEffect(e91)
  end
  -- 【常】「対戦相手の効果によって、対戦相手のシグニのパワーは＋されない」는 아직
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetRange(LOCATION_KEY)
  e3:SetCountLimit(1)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e3:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,5000)
    end
  end)
  c:RegisterEffect(e3)
end
