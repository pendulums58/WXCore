-- WXK04-005 カーニバル　－Ｋ－
-- 【常】：あなたのセンタールリグは以下の能力を得る。
-- 【起】《ターン１回》《アタックフェイズアイコン》エクシード１：ターン終了時まで、対象のあなたのシグニ１体はあなたのトラッシュにある対象のシグニ１枚と同じカードになる。
-- 【出】：あなたのデッキからレベル４のシグニを２枚まで探して公開し手札に加え、デッキをシャッフルする。
-- 【起】《アタックフェイズアイコン》このキーを場からルリグトラッシュに置く：ターン終了時まで、対戦相手のすべてのシグニを《サーバント ＺＥＲＯ》にする。
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
      Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil)
    end)
    g:SetOperation(function(e,tp)
      local mine,src=nil,nil
      for x in Duel.GetTargets():Iter() do if x:IsLocation(LOCATION_SZONE) then mine=x else src=x end end
      if not (mine and src and mine:IsRelateToEffect(e) and src:IsRelateToEffect(e)) then return end
      -- [まで] ターン終了時まで 「同じカードになる」
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_COPY)
      e1:SetValue(src:GetCode())
      e1:SetReset(RESET_PHASE+PHASE_END)
      mine:RegisterEffect(e1)
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
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp,eg)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and x:GetLevel()==4 end,2)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetRange(LOCATION_KEY)
  e3:SetTiming(TIMING_ATTACK)
  e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) end
    Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
  end)
  e3:SetOperation(function(e,tp,eg)
    for x in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do
      -- 「《サーバント　ＺＥＲＯ》にする」: 능력 상실·기본 파워 1000·레벨 1로 근사(WX17-005와 같다)
      local z1=Effect.CreateEffect(e:GetHandler())
      z1:SetType(EFFECT_TYPE_SINGLE)
      z1:SetCode(EFFECT_LOSE_ABILITY)
      z1:SetReset(RESET_PHASE+PHASE_END)
      x:RegisterEffect(z1)
      local z2=Effect.CreateEffect(e:GetHandler())
      z2:SetType(EFFECT_TYPE_SINGLE)
      z2:SetCode(EFFECT_SET_BASE_POWER)
      z2:SetValue(1000)
      z2:SetReset(RESET_PHASE+PHASE_END)
      x:RegisterEffect(z2)
      local z3=Effect.CreateEffect(e:GetHandler())
      z3:SetType(EFFECT_TYPE_SINGLE)
      z3:SetCode(EFFECT_CHANGE_LEVEL)
      z3:SetValue(1)
      z3:SetReset(RESET_PHASE+PHASE_END)
      x:RegisterEffect(z3)
    end
  end)
  c:RegisterEffect(e3)
end
