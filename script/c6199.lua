-- WXK01-007 ドーナ　ＣＨＥＥＲ
-- 【常】：あなたのセンタールリグは以下の能力を得る。
-- 【起】《アタックフェイズアイコン》エクシード４：このターン、シグニアタックステップをスキップする。
-- 【起】《アタックフェイズアイコン》エクシード４：このターン、ルリグアタックステップをスキップする。
-- 【出】：あなたのシグニ１体を対象とし、ターン終了時まで、それは「【常】：バニッシュされない。」を得る。
-- 【起】このキーを場からルリグトラッシュに置く：あなたのデッキからシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  do
    local g=Effect.CreateEffect(c)
    g:SetType(EFFECT_TYPE_IGNITION)
    g:SetDescription(aux.Ability(id,1))
    g:SetRange(LOCATION_LRIG)
    g:SetExceedCost(4)
    g:SetTiming(TIMING_ATTACK)
    g:SetOperation(function(e,tp)
      -- [の間] 「このターン」 추가 어택 페이즈도(FAQ 2)
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD)
      e1:SetCode(EFFECT_SKIP_SIGNI_ATTACK)
      e1:SetTargetRange(1,1)
      e1:SetReset(RESET_PHASE+PHASE_END)
      Duel.RegisterEffect(e1,tp)
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
  do
    local g=Effect.CreateEffect(c)
    g:SetType(EFFECT_TYPE_IGNITION)
    g:SetDescription(aux.Ability(id,2))
    g:SetRange(LOCATION_LRIG)
    g:SetExceedCost(4)
    g:SetTiming(TIMING_ATTACK)
    g:SetOperation(function(e,tp)
      -- [の間] 「このターン」
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD)
      e1:SetCode(EFFECT_SKIP_LRIG_ATTACK)
      e1:SetTargetRange(1,1)
      e1:SetReset(RESET_PHASE+PHASE_END)
      Duel.RegisterEffect(e1,tp)
    end)
    local e92=Effect.CreateEffect(c)
    e92:SetType(EFFECT_TYPE_FIELD)
    -- [の間] 【常】 센터 루리그가 얻는다
    e92:SetDescription(aux.Ability(id,0))
    e92:SetCode(EFFECT_GRANT)
    e92:SetRange(LOCATION_KEY)
    e92:SetTargetRange(LOCATION_LRIG,0)
    e92:SetLabelObject(g)
    c:RegisterEffect(e92)
  end
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e3:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.GrantKeyword(e,tc,EFFECT_CANNOT_BANISH)  -- [まで] ターン終了時まで
    end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_IGNITION)
  e4:SetDescription(aux.Ability(id,4))
  e4:SetRange(LOCATION_KEY)
  e4:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) end
    Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
  end)
  e4:SetOperation(function(e,tp,eg)
    aux.SearchToHand(tp,Card.IsSigni,1)
  end)
  c:RegisterEffect(e4)
end
