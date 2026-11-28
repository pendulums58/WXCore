-- WXK04-002 英血の器　優羽莉　Ｌｖ４’
-- 【常】：あなたの血晶武装状態のシグニは対戦相手のルリグの効果を受けない。
-- 【起】《ターン１回》《赤×0》：あなたの＜紅蓮＞のシグニ１体を対象とし、それを血晶武装［手札かトラッシュ］する。
-- 【起】《ゲーム１回》アルティメットレイド《コインアイコン》：以下の５つから２つを選ぶ。あなたのシグニ１体を対象とし、ターン終了時まで、それは選んだ能力を得る。①【アサシン】②【ダブルクラッシュ】③「【常】：バニッシュされない。」④「【常】：対戦相手の効果によってダウンしない。」⑤「【常】：対戦相手の効果によって手札に戻らない。」
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x:IsSigni() and x:IsBloodArmed() end)
  e1:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and sc:IsType(TYPE_LRIG) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_GUREN) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.BloodArm(tp,tc,LOCATION_HAND+LOCATION_TRASH)
    end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(1,true)
  e3:SetCoinCost(1)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e3:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    local codes={EFFECT_ASSASSIN,EFFECT_DOUBLE_CRUSH,EFFECT_CANNOT_BANISH,EFFECT_NO_DOWN_BY_OPP,EFFECT_NO_BOUNCE}
    for _,i in ipairs(Duel.SelectModes(tp,2,2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3),aux.Stringid(id,4))) do
      aux.GrantKeyword(e,tc,codes[i+1])  -- [まで] ターン終了時まで. ⑤는 자기 효과도 막는 근사
    end
  end)
  c:RegisterEffect(e3)
end
