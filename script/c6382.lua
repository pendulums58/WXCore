-- WXK03-006 添遂の閻魔　ウリス
-- 【常】：あなたのセンタールリグは以下の能力を得る。
-- 【起】《ターン１回》《アタックフェイズアイコン》エクシード１：対象のあなたのシグニ１体を場からトラッシュに置く。そうした場合、そのシグニと同じレベルの対象の対戦相手のシグニ１体をバニッシュする。
-- 【常】：あなたのセンタールリグは黒になる。
-- 【起】《ターン１回》《アタックフェイズアイコン》《黒×0》：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのレベルを－１する。
local s,id=GetID()
function s.initial_effect(c)
  do
    local g=Effect.CreateEffect(c)
    g:SetType(EFFECT_TYPE_IGNITION)
    g:SetDescription(aux.Ability(id,1))
    g:SetRange(LOCATION_LRIG)
    g:SetExceedCost(1)
    g:SetTiming(TIMING_ATTACK)
    g:SetCountLimit(1)
    g:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
      if chk==0 then return true end
      Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
      Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,1,nil)
    end)
    g:SetOperation(function(e,tp)
      local g=Duel.GetTargets()
      local mine,opp=nil,nil
      for x in g:Iter() do if x:GetControler()==tp then mine=x else opp=x end end
      if not (mine and mine:IsRelateToEffect(e)) then return end
      local lv=mine:GetLevel()
      -- 레조나도 된다(FAQ 4)
      if Duel.SendToTrash(mine,REASON_EFFECT)==0 then return end
      if opp and opp:IsRelateToEffect(e) and opp:GetLevel()==lv then Duel.Banish(opp) end
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
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EFFECT_CHANGE_COLOR)
  e2:SetRange(LOCATION_KEY)
  e2:SetTargetRange(LOCATION_LRIG,0)
  e2:SetValue(COLOR_BLACK)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetRange(LOCATION_KEY)
  e3:SetTiming(TIMING_ATTACK)
  e3:SetCountLimit(1)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      -- [まで] ターン終了時まで. 0까지(FAQ 3)
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_UPDATE_LEVEL)
      e1:SetValue(-1)
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:RegisterEffect(e1)
    end
  end)
  c:RegisterEffect(e3)
end
