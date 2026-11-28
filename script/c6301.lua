-- WXK02-023 アイヤイ★ディール
-- 【常】：対戦相手のセンタールリグがレベル２以上であるかぎり、あなたのセンタールリグは以下の能力を得る。
-- 【起】《ターン１回》エクシード２（あなたのルリグの下からカードを合計２枚ルリグトラッシュに置く）：あなたのシグニ１体を対象とし、ターン終了時まで、それは「【自】《ターン１回》：このシグニがアタックしたとき、このシグニをアップする。」を得る。
-- 【常】：あなたがエナコストを支払う際、このキーを場からルリグトラッシュに置くことで好きな色のエナ２つを支払える。
local s,id=GetID()
function s.initial_effect(c)
  do
    local g=Effect.CreateEffect(c)
    g:SetType(EFFECT_TYPE_IGNITION)
    g:SetDescription(aux.Ability(id,1))
    g:SetRange(LOCATION_LRIG)
    g:SetExceedCost(2)
    g:SetCountLimit(1)
    g:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
      if chk==0 then return true end
      Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
    end)
    g:SetOperation(function(e,tp)
      local tc=Duel.GetFirstTarget()
      if not (tc and tc:IsRelateToEffect(e)) then return end
      local g=Effect.CreateEffect(e:GetHandler())
      g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
      g:SetDescription(aux.Stringid(id,0))
      g:SetCode(EVENT_ATTACK)
      g:SetCountLimit(1)
      g:SetOperation(function(e2) local h=e2:GetHandler() if h:IsLocation(LOCATION_SZONE) then Duel.Up(h) end end)
      g:SetReset(RESET_PHASE+PHASE_END)
      tc:GrantEffect(g)
    end)
    local e91=Effect.CreateEffect(c)
    e91:SetType(EFFECT_TYPE_FIELD)
    -- [の間] 【常】 센터 루리그가 얻는다
    e91:SetDescription(aux.Ability(id,0))
    e91:SetCode(EFFECT_GRANT)
    e91:SetRange(LOCATION_KEY)
    e91:SetTargetRange(LOCATION_LRIG,0)
    e91:SetCondition(function(e) local oc=Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),0,LOCATION_LRIG,nil):GetFirst() return oc and oc:GetLevel()>=2 end)
    e91:SetLabelObject(g)
    c:RegisterEffect(e91)
  end
  -- 【常】「エナコストを支払う際、このキーを…好きな色のエナ２つ」는 아직(지불 수단이 에나 존 카드뿐이다)
end
